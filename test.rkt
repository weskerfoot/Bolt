#! /usr/bin/env racket
#lang racket

(require bolt)

(define linode
    (remote
    #:host "linode"
    #:user "wes"
    #:key "/home/wes/.ssh/id_rsa.key"))

(define (test)
  (with-cwd "gforth"
    (exec "sudo whoami")
    (with-cwd "src"
      (pwd)
      (ls)
      (with-cwd "gforth-0.7.3"
        (ls))))
  (pwd)
  (exec "cat /etc/passwd")
  (become "http" (ls)))

; This is based on an entry in ~/.ssh/config
(with-host linode
  (become "root"
    (become "http"
      (pwd)
      (exec "ls /etc"))
    (pwd))
  (pwd))
