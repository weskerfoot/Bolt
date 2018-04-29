#lang racket

(require remote-shell/ssh)
(require "directory.rkt")
(require "shell_env.rkt")

(define (strip-first-line st)
  (string-join
   (cdr
    (string-split st "\n"))
   "\n"))

(define cwd
  (make-parameter "~"))

(define host
  (make-parameter #f))

(define hostname
  (make-parameter #f))

(define user
  (make-parameter #f))

(define commands
  (make-parameter #f))

(define-syntax-rule
  (plan expr ...)
  (parameterize
      ([commands (list)])
    (begin expr ...)))

(define-syntax-rule
  (with-cwd dir expr ...)
  (parameterize
    ([cwd
      (match (substring dir 0 1)
        ["/" dir]
        [_ (format "~a/~a" (cwd) dir)])])
    (begin expr ...)))

(define-syntax-rule
  (with-host remote expr ...)
  (parameterize
    ([host remote]
     [hostname (remote-host remote)])
     (begin expr ...)))

(define-syntax-rule
  (become username expr ...)
  (parameterize
      ([user username])
    (begin expr ...)))

(define (as-user cmd)
  (if
   (user)
     (format "sudo -u ~a ~a sh -c \"~a\""
             (user)
             (format-vars)
             cmd)
   cmd))

(define (exec cmd)
  (displayln
    (format "Executed on ~a:" (remote-host (host))))
  (match
      (ssh (host)
       (as-user
        (string-append
         (format "cd ~a && "
                 (cwd))
         cmd))
       #:failure-log "/tmp/test.log"
       #:mode 'output)
    [(cons code output)
     (cons code
           (strip-first-line
            (bytes->string/utf-8 output)))]
    [output output]))

(define (copy-file source dest)
  (displayln
    (format "Copying file to ~a:" (remote-host (host))))
  (scp
    (host)
    source
    (format "~a@~a:~a" (user) (remote-host (host)) dest)
    #:mode 'result))

(define (copy-dir source dest)
  (define tar-path (compress source))
  (copy-file tar-path tar-path)
  (remove-tmp tar-path)
  (exec (format "mkdir -p ~a" dest))
  (exec (format "tar -xzvf ~a -C ~a" tar-path dest))
  (exec (format "rm ~a" tar-path)))

(define ((make-cmd cmd)) (exec cmd))

(define ls (make-cmd "ls"))
(define pwd (make-cmd "pwd"))

(provide
  (all-defined-out)
  remote
  compress
  with-shell-vars)
