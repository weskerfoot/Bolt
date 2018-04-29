#lang racket

(define default-shell-vars
  #hash(
        ("LANG" . "en_US.UTF-8")))

(define shell-env
  (make-parameter default-shell-vars))

(define (remove-dups xs ys)
  (define dups
    (set-intersect (map car xs)
                   (map car ys)))
  (define new-xs
    (filter-not
      (compose1
        (lambda (x) (member x dups))
        car)
      xs))
    new-xs)

(define (merge-hash h1 h2)
  (define h1-vs (hash->list h1))
  (define h2-vs  (hash->list h2))
  (define new-h2-vs (remove-dups h2-vs h1-vs))
  (make-hash (append new-h2-vs h1-vs)))

(define (merge-hashes . hs)
  (foldl merge-hash #hash() hs))

(define (set-vars vars)
  (apply
    merge-hashes
    (list
      (shell-env)
      (make-hash vars))))

(define (format-vars)
  (string-join
    (hash-map
      (shell-env)
      (lambda (k v)
        (format "export ~a=~a;" k v)))))

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
