#lang scribble/manual
@(require "base.rkt")

@title{Transport Connectors}
@defmodule[net2/connector #:no-declare]
@declare-exporting[net2/connector net2]

A @connector-tech[#:definition? #t]{connector} is a means of opening new
@transport-tech{transports} to arbitrary @authority-tech{authorities}.
Connectors play the role of a "client" authority in the sense that they send
connection requests to "server" authorities, but once an authority accepts that
request and opens a new transport either party may send or receive bytes to the
other at any time. To instead accept connection requests from others, see
@listener-tech{listeners}.

The @racketmodname[net2/connector] module defines a means of constructing new
connectors as well as generic ways of extending connectors. For connectors that
use the operating system's networking including TCP connectors, see the
@racketmodname[net2/system] module.

@section{Connector Concepts}

Connectors are typically responsible for all connections of a specific kind in a
program, regardless of which @thread-tech{thread} attempts to connect to which
authority. This allows connectors to reuse connections across threads without
fear that a @custodian-tech{custodian} shutdown in one thread will close a
transport used by another thread. Connector transport reuse and management is
primarily defined in terms of @disposable-tech{disposables} from the
@racketmodname[disposable] library.

Note that many kinds of transports (including TCP connections) are expensive to
create, maintain, and terminate. It is crucial to minimize the number of open
connections between two parties. However, transports are not thread safe in the
sense that two threads attempting to serialize and deserialize complex messages
directly to the same transport will interleave their bytes on the wire, leading
to mangled and uninterpretable messages. To prevent threads from concurrently
writing messages while simultaneously limiting open connections, use a dedicated
thread for serializing and deserializing messages from a message buffer which
other threads read and write messages to atomically, instead of providing all
threads with direct access to the underlying transport.

@section{Connector Primitives}

@defproc[(connector? [v any/c]) boolean?]{
 Returns @racket[#t] if @racket[v] is a @connector-tech{connector}.}

@defproc[(connector [connect-proc (-> authority? (disposable/c transport?))]
                    [#:custodian cust (make-custodian)])
         connector?]{
 Returns a @connector-tech{connector} that can be used with @racket[connect] to
 open new @transport-tech{transports} to a given @authority-tech{authority}.
 Calls to @racket[connect-proc], allocation of the @disposable-tech{disposable}
 it returns, and deallocation of allocated transports are all made with
 @racket[cust] installed as the @current-cust-tech{current custodian} to ensure
 that all @port-tech{ports} are managed solely by the returned connector. If
 @racket[cust] is not provided it defaults to a new custodian that is a child of
 the custodian that was current when @racket[connector] was called.

 The @racket[connect-proc] procedure is expected to choose a source authority
 for outgoing transports, as well as resolve the destination authority from a
 resolvable name authority (such as a DNS address) to a more direct network
 address authority (such as an IP address). As a result, transports created by
 @racket[connect-proc] may have a different destination authority than the
 destination authority oringally provided to @racket[connect-proc].

 Cleanly closing transports may involve negotiating shutdown actions with the
 destination authority. The @disposable-tech{disposable} returned by
 @racket[connect-proc] is expected to responsibly implement this sort of
 graceful close logic, with forceful termination of the transport left to
 @custodian-tech{custodian} shutdowns and finalizers. See @secref[
 "transport-cleanup"] for a more in-depth discussion.}

@defproc[(connect! [conn connector?] [dest authority?]) transport?]{
 Connects to @racket[dest] using @racket[conn] and returns a @transport-tech{
  transport} that can be used to communicate with @racket[dest], albeit possibly
 with a different address for the destination @authority-tech{authority} due to
 name resolution. If @racket[conn] opens @port-tech{ports} or other resources
 managed by @custodian-tech{custodians}, those resources are owned by the
 custodian used to construct @racket[conn] instead of the @current-cust-tech{
  current custodian}. See @racket[connector] for more details.

 The returned transport is created for use only in the current thread and
 automatically destroyed when the current thread dies, but the meaning of
 "destroyed" is dependent on the specific @connector-tech{connector} used. In
 particular, some connectors may reuse transports in the future. For precise
 control over construction and destruction of transports, see the
 @racket[connection] procedure.}

@defproc[(connection [conn connector?]
                     [dest authority?]
                     [#:fresh-only? fresh-only? #f])
         (disposable/c (list transport? (-> void?)))]{
 @;; TODO: document how this allows controlling when connections are reused
 @;; Also possibly use some explicit "lease" type exposed in disposable
 Currently undocumented.}

@section{Composing and Extending Connectors}

@defproc[(connector-tunnel [conn connector?]
                           [tunneler (-> transport? (disposable/c transport?))])
         connector?]{
 Returns a @connector-tech{connector} that is like @racket[conn], except that
 after constructing a @transport-tech{transport} with @racket[conn] (such as in
 a call to @racket[connect!]) the @racket[tunneler] procedure is used to layer a
 new protocol on top of the transport. This is most commonly used to convert an
 insecure TCP connection to a secure TLS connection with @racket[tls-transport],
 but other use cases exist.

 The @disposable-tech{disposable} returned by @racket[tunneler] is responsible
 only for setting up and tearing down the new protocol @emph{on top of} an
 already existing transport --- it is not responsible for creating or destroying
 the underlying transport being tunneled over. As a consequence, this allows
 opening and closing a tunnel multiple times on the same transport if
 @racket[conn] reuses transports. To control whether or not a tunnel should use
 a fresh transport, see the @racket[connection] procedure.

 Tunnel disposables are not expected to created new @port-tech{ports} or other
 @custodian-tech{custodian} managed resources due to their reuse of an existing
 transport, but in the event one does they will be created under supervision of
 a @emph{new} custodian that is subordinate to the custodian of @racket[conn],
 not the @current-cust-tech{current custodian}.}

@; TODO: figure out connection pooling API
