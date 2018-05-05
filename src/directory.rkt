#lang racket

(require racket/system)

(define (clean-path path)
  (string-replace path "/" "_"))

(define (compress directory)
  (define tar
    (find-executable-path "tar"))

  (define path
    (format "/tmp/~a.tar.gz"
            (clean-path directory)))

  (system* tar "-zcvf" path "-C" directory ".")
  path)

(define (remove-tmp path)
  (define rm
    (find-executable-path "rm"))
  (system* rm path))

(define (drop-last-dir path)
  (define ps (explode-path path))
  (define paths (take ps (sub1 (length ps))))
  (path->string
    (apply build-path paths)))

(provide
  drop-last-dir
  compress
  remove-tmp)
