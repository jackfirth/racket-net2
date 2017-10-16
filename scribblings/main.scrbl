#lang scribble/manual

@(require "base.rkt")

@(define github-url "https://github.com/jackfirth/racket-net2")
@(define license-url
   "https://github.com/jackfirth/racket-net2/blob/master/LICENSE")

@title{Net2: Evolved Networking Libraries}
@defmodule[net2 #:packages ("net2")]
@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

The @racketmodname[net2] library is a framework for building networked
communication protocols. It defines several abstractions for establishing
connections to other parties in an abstract network, as well as tools for high-
level communication between those parties.

Included in @racketmodname[net2] is a full HTTP2 client and server
implementation, allowing Racket programs to communicate over TLS-encrypted HTTP2
via TCP connections over the Internet, machine-local UNIX domain sockets, or
in-memory pipes within a single Racket process. This functionality is defined
across several modules:

@itemlist[
 @item{@racketmodname[net2] --- Provides everything and the kitchen sink.}
 @item{@racketmodname[net2/data] --- Spec-compliant definitions of various kinds
  of networking data, including IP addresses, DNS names, and URIs.}
 @item{@racketmodname[net2/transport] --- Defines @transport-tech{transports},
  which abstract over sending and receiving bytes reliably between two networked
  parties.}
 @item{@racketmodname[net2/connector] --- Defines @connector-tech{connectors}
  for opening new @transport-tech{transports} with other parties.}
 @item{@racketmodname[net2/listener] --- Defines @listener-tech{listeners} for
  accepting requests from other parties to open new @transport-tech{
   transports}.}
 @item{@racketmodname[net2/system] --- Access to built-in networking provided by
  the operating system, including TCP connections, UNIX domain sockets, and TLS
  encrypted communication with OpenSSL.}]

Source code for this library is avaible @hyperlink[github-url]{on Github} and is
provided under the terms of the @hyperlink[license-url]{Apache License 2.0}.

@local-table-of-contents[]

@include-section["data.scrbl"]
@include-section["transport.scrbl"]
@include-section["connector.scrbl"]
@include-section["listener.scrbl"]
@include-section["system.scrbl"]
