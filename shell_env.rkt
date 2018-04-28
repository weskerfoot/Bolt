#lang racket

(define shell-env
  (make-parameter #hash()))

(define (merge-hash h1 h2)
  (define h1-vs (hash->list h1))
  (define h2-vs  (hash->list h2))
  (make-hash (append h1-vs h2-vs)))

(define (merge-hashes . hs ...)
  (foldl merge-hash #hash() hs))

(define (set-vars vars)
  (apply
    merge-hashes
    (list
      (shell-env)
      (make-hash vars))))
