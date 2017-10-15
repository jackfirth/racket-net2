#lang info

(define name "net2")
(define collection "net2")

(define deps
  '("base"))

(define build-deps
  '("racket-doc"
    "scribble-lib"))

(define scribblings
  '(("scribblings/main.scrbl" () (library) "net2")))
