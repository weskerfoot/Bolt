#! /usr/bin/env racket
#lang racket

(require bolt)

; This is based on an entry in ~/.ssh/config
(define primop
    (remote
    #:host "linode"
    #:user "wes"
    #:key "/home/wes/.ssh/id_rsa.key"))

(define (deploy)
  (with-host primop
    (with-shell-vars
      (["a" "b"])
      (become "wes"
      (copy-dir "../pricewatch" "/home/wes/pricewatch")

      (with-cwd "/home/wes/pricewatch"

        (become "root"
          (exec "pip install pipenv"))

        (with-cwd "checks"
          (exec "pipenv install")))))))

(deploy)
