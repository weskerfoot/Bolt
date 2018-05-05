#lang racket

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

(define (format-vars env)
  (string-join
    (hash-map
      env
      (lambda (k v)
        (format "export ~a=~a;" k v)))))

(provide
  (all-defined-out))
