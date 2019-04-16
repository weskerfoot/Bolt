#lang racket

(require remote-shell/ssh)
(require "directory.rkt")
(require "shell_env.rkt")
(require "parameters.rkt")

;; Helper function
(define (strip-first-line st)
  (string-join
   (cdr
    (string-split st "\n"))
   "\n"))

(define (as-user cmd)
  (if
   (user)
     (format "sudo -u ~a sh -c '~a'"
             (user)
             cmd)
   cmd))

(define (exec cmd)
  (displayln
    (format "Executed on ~a:" (remote-host (host))))
  (match
      ((executor)
       (as-user
         (format "cd ~a && ~a ~a"
                 (cwd)
                 (format-vars (shell-env))
                 cmd)
         ))
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
  (all-from-out remote-shell/ssh)
  (all-from-out "parameters.rkt")
  (all-from-out "directory.rkt")
  (all-from-out "shell_env.rkt")
  (all-defined-out))
