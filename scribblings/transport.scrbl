#lang scribble/manual
@(require "base.rkt")

@title{Transports}
@defmodule[net2/transport #:no-declare]
@declare-exporting[net2/transport net2]

A @transport-tech[#:definition? #t]{transport} is a means of reliably sending
and receiving bytes between two named parties across some network. TCP
connections over an IP network serve as a canonical example, with the two
parties named by their IP addresses and port numbers. A transport pairs an
@input-port-tech{input port} and an @output-port-tech{output port} with two
@authority-tech{authorities}: one naming the party using those ports, and one
naming the party "on the other end" of the connection. Transports can be
directly constructed from ports with @racket[transport].

Transports do not have a notion of clients and servers --- once established, a
transport can be used for arbitrary bidirectional communication. For a
high-level interface to client-server transport creation, see @connector-tech{
 connectors} and @listener-tech{listeners}. Also see the
@racketmodname[net2/system] module for access to operating system transports
such as TCP connections.

Transports are not thread safe in the sense that two threads attempting to
serialize and deserialize complex messages directly to the same transport will
interleave their bytes on the wire, leading to mangled and uninterpretable
messages. To prevent threads from concurrently writing messages without opening
multiple transports between the same authorities, use a dedicated thread for
serializing and deserializing messages from a message buffer which other threads
read and write messages to atomically instead of sharing the connection
directly.

@section{Transport Primitives}

@defproc[(transport? [v any/c]) boolean?]{
 Returns @racket[#t] if @racket[v] is a @transport-tech{transport}.}

@defproc[(transport [#:in in input-port?]
                    [#:out out output-port?]
                    [#:source source authority?]
                    [#:dest dest authority?])
         transport?]{
 Constructs a @transport-tech{transport} that acts as @racket[source]
 communicating with @racket[dest] by reading data from @racket[in] and sending
 data to @racket[out]. Using this constructor is expected to be rare; most
 transports are created with procedures like @racket[tcp-connect] or tunneled
 over existing transports with procedures like @racket[tls-transport].}

@deftogether[
 (@defproc[(transport-in [trans transport?]) input-port?]
   @defproc[(transport-out [trans transport?]) output-port?]
   @defproc[(transport-source [trans transport?]) authority?]
   @defproc[(transport-dest [trans transport?]) authority?])]{
 Accessors for the various components of a @transport-tech{transport} as passed in to
 the @racket[transport] constructor.}

@section[#:tag "transport-cleanup"]{Transport Cleanup and Disposables}

The @transport-tech{transport} API does not offer any means of directly
overriding how a transport is shut down except for making @custom-port-tech{
 custom ports} that perform special cleanup actions when closed. Broadly, this
is because there are only two kinds of cleanup actions one might want to perform
on a transport:

@itemlist[
 @item{@emph{System cleanup actions} that free local operating system resources,
  such as releasing file descriptors associated with the input and output
  @port-tech{ports}.}
 @item{@emph{Connection cleanup actions} that send messages to the transport's
  destination @authority-tech{authority} in an attempt to negotiate a graceful
  connection termination, such as TCP's use of FIN packets.}]

System cleanup actions are usually associated directly with a single
@input-port-tech{input port} or @output-port-tech{output port} --- not with the
transport as a whole. As a result, it's best to implement system cleanup within
a custom port's close procedure and rely on it being called when the port is
closed or when the port's @custodian-tech{custodian} is shut down.

Connection cleanup actions involve coordination and communication with another
party over a network. @bold{Connection cleanup is inherently unreliable.} There
is no way to guarantee that communication with the other party won't abrubtly
terminate at any point. Therefore, connection cleanup should be performed on a
@emph{best effort} basis that tolerates failure. It is inappropriate to perform
connection cleanup actions during a custodian shutdown using
@racketmodname[ffi/unsafe/custodian], because custodian shutdowns are performed
unsafely and expected to always succeed with very little (if any) IO.

To properly implement connection cleanup actions in transports, many interfaces
in @racketmodname[net2] require that connection cleanup logic is encapsulated in
a @disposable-tech{disposable} from the @racketmodname[disposable] library. This
allows declaratively specifying how and when connection termination logic will
execute, and reduces the complexity involved in adding timeout and early
termination logic. See @racket[tcp-connector] for an example of constructing
transports with robust and graceful connection termination. Alternatively, refer
to @connector-tech{connectors} and @listener-tech{listeners} for information on
how they encapsulate connection termination with disposables and custodians.
