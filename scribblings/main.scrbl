#lang scribble/manual

@(require "base.rkt")

@title{Net2: Evolved Networking Libraries}
@defmodule[net2 #:packages ("net2")]
@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

The @racketmodname[net2] library is a framework for building networked
communication protocols. It defines several abstractions for establishing
connections to other parties in a network, as well as tools for high-level
communication between those parties.

Included in the @racketmodname[net2] library is a full HTTP2 client and server
implementation, allowing Racket programs to communicate over TLS-encrypted HTTP2
via TCP connections over the Internet, via UNIX domain socket connections on the
same machine, or via in-memory pipes within a single Racket process. This
functionality is defined in several modules:

@itemlist[
 @item{@racketmodname[net2/data] --- Spec-compliant definitions of various kinds
  of networking data, including IP addresses, DNS names, and URIs.}
 @item{@racketmodname[net2/transport] --- Defines @transport-tech{transports},
  which abstract over sending and receiving bytes reliably between two network
  parties.}
 @item{@racketmodname[net2/connector] --- Defines @connector-tech{connectors}
  for opening new transports with other parties.}
 @item{@racketmodname[net2/listener] --- Defines @listener-tech{listeners} for
  accepting requests from other parties to open new transports.}
 @item{@racketmodname[net2/system] --- Access to built-in networking provided by
  the operating system, including TCP connections, UNIX domain sockets, and TLS
  encrypted communication with OpenSSL.}]

@local-table-of-contents[]

@include-section["data.scrbl"]
