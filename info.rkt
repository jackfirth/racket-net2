#lang info

(define name "net2")
(define collection "net2")

(define deps
  '("reprovide-lang"
    "base"))

(define build-deps
  '("disposable"
    "racket-doc"
    "scribble-lib"))

(define scribblings
  '(("scribblings/main.scrbl" (multi-page) (library) "net2")))
