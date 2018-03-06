#lang info
(define collection "bolt")
(define deps '("base"
               "rackunit-lib"
               "remote-shell"))

(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/bolt.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(wes))
