#lang racket

(require "utils.rkt")

(define default-env
  #hash(
        ("LANG" . "en_US.UTF-8")))
(struct
  UserCommand
  (username cmd))

(struct
  WithDirectoryCommand
  (directory cmd))

(struct
  ExecCommand
  (command env))

(define (printshell stx)
  (match stx
    [(WithDirectoryCommand directory cmd)
     (format "cd ~a; ~a" directory (printshell cmd))]

    [(UserCommand username cmd)
     (format "sudo -u ~a sh -c '~a'"
             username
             (printshell cmd))]

    [(ExecCommand command env)
     (define funcname (gensym))
     (format "function ~a { ~a ~a; }; ~a"
             funcname
             (format-vars env)
             command
             funcname)]))

(displayln
  (printshell
    (WithDirectoryCommand "/home/wes"
        (UserCommand "wes"
          (ExecCommand "echo $LANG" default-env)))))
