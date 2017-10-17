#lang racket/base

(require "util.rkt")

(define-tech-helpers
  uri-tech "uri"
  scheme-tech "uri scheme"
  authority-tech "uri authority"
  host-tech "uri host"
  reg-name-tech "uri registered name"
  path-tech "uri path"
  query-tech "uri query"
  fragment-tech "uri fragment"
  lookup-tech "name lookup"
  fed-ns-tech "federated namespace")

(define-tech-helpers
  transport-tech "transport"
  connector-tech "connector"
  listener-tech "listener")

(define-tech-helpers
  disposable-tech "disposable" disposable/scribblings/main
  port-tech "port" scribblings/guide/guide
  input-port-tech "input port" scribblings/reference/reference
  output-port-tech "output port" scribblings/reference/reference
  custom-port-tech "custom ports" scribblings/reference/reference
  custodian-tech "custodian" scribblings/reference/reference
  current-cust-tech "current custodian" scribblings/reference/reference
  thread-tech "threads" scribblings/guide/guide)
