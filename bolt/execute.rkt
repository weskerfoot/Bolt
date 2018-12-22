#! /usr/bin/env racket
#lang racket

(define (read-avail from-port callback)
  (define ready
    (sync
      (read-bytes-evt 1 from-port)))

  (if (not (eof-object? ready))
      (begin
        (callback ready)
        (read-avail from-port callback))
      (callback #f)))


(define (execute-async to-port)
  (define command (thread-receive))

  (displayln command to-port)

  (flush-output to-port)
  (execute-async to-port))

;; you tell it the remote, and pass it a callback
;; the callback gets hooked into another thread that waits for output
;; the callback executes on any output
;; the output might be parsed into a standard format

(define (make-executor host callback)

  (match-define (list from-remote
                      to-remote
                      pid
                      error-from-remote
                      control-remote)
    (process (format "ssh -tt ~a" host)))

  (thread
    (lambda () (read-avail from-remote callback)))

  (define
    executor
    (thread (lambda () (execute-async to-remote))))

  (lambda (command)
    (thread-send executor command)))

(define (make-exec hostname)
  (make-executor
    hostname
    (lambda (result)
      (display result))))

(provide make-exec)
