#lang racket/base

(provide define-tech-helpers)

(require (for-syntax racket/base)
         scribble/manual
         syntax/parse/define)


(define ((tech-helper key mod) #:definition? [definition? #f] . pre-flow)
  (if definition?
      (apply deftech #:key key pre-flow)
      (apply tech #:key key #:doc (and mod (mod->docpath mod)) pre-flow)))

(define (mod->docpath mod)
  `(lib ,(format "~a.scrbl" mod)))

(define-simple-macro
  (define-tech-helpers
    (~seq id:id key:str (~optional mod:id #:defaults ([mod #'#f]))) ...)
  (begin (begin (define id (tech-helper key 'mod)) (provide id)) ...))
