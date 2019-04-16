#lang racket

(require remote-shell/ssh)
(require "execute.rkt")

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

(define executor
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
     [hostname (remote-host remote)]
     [executor (make-exec (remote-host remote))])
     (begin expr ...)))

(define-syntax-rule
  (become username expr ...)
  (parameterize
      ([user username])
    (begin expr ...)))

(provide
  (all-defined-out))
