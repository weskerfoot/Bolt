#lang racket

(require "utils.rkt")

(define default-shell-vars
  #hash(
        ("LANG" . "en_US.UTF-8")))

(define shell-env
  (make-parameter default-shell-vars))

(define (merge-hashes . hs)
  (foldl merge-hash #hash() hs))

(define (set-vars vars)
  (apply
    merge-hashes
    (list
      (shell-env)
      (make-hash vars))))

(define-syntax join-shell-vars
  (syntax-rules ()
    [(join-shell-vars (k v))
     (merge-hash
       (make-hash
         (list (cons k v)))
       (shell-env))]

    [(join-shell-vars (k v) rest ...)
     (merge-hash
       (make-hash (list (cons k v)))
       (join-shell-vars rest ...))]))

(define-syntax with-shell-vars
  (syntax-rules ()
    [(with-shell-vars (vars ...) expr ...)
      (parameterize
        [(shell-env (join-shell-vars vars ...))]
        (begin expr ...))]))

(provide
  shell-env
  merge-hashes
  set-vars
  format-vars
  with-shell-vars)
