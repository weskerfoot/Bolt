Bolt
====

Bolt is an automation DSL, similar to [http://fabfile.org](http://fabfile.org)

### Installation
```
git clone git@github.com:weskerfoot/Bolt.git
raco pkg install --link bolt
```

Example:

```
#! /usr/bin/env racket
#lang racket

(require bolt)

; This is based on an entry in ~/.ssh/config
(define metaverse
    (remote
    #:host "hostname"
    #:user "alice"
    #:key "/home/alice/.ssh/id_rsa.key"))

(define (deploy)
  (with-host metaverse
    (with-shell-vars
      (["FOO" "BAR"])
      (become "alice"
        (copy-dir "../mycode" "/home/alice/mycode")

        (with-cwd "/home/alice/mycode"

          (become "root"
            (exec "pip install pipenv"))

          (with-cwd "project"
            (exec "pipenv install")))))))
(deploy)
```
