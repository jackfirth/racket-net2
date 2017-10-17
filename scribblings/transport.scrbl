#lang scribble/manual
@(require "base.rkt")

@title{Transports}
@defmodule[net2/transport #:no-declare]
@declare-exporting[net2/transport net2]

A @transport-tech[#:definition? #t]{transport} is a means of reliably sending
and receiving bytes between two named parties across some network. TCP
connections serve as a canonical example. Concretely, a transport pairs an input
@port-tech{port} and an output @port-tech{port} with two @authority-tech{
 authorities}: one representing the party using those ports, and one
representing the party "on the other end" of the connection. Transports can be
directly constructed with @racket[transport].

Transports do not directly have a notion of clients and servers --- once
established, a transport can be used for arbitrary bidirectional communication.
For a high-level interface to transport creation, see @connector-tech{
 connectors} and @listener-tech{listeners}. See also @racketmodname[net2/system]
for access to operating system transports such as TCP connections.

@defproc[(transport? [v any/c]) boolean?]{
 Returns @racket[#t] if @racket[v] is a @transport-tech{transport}.}

@defproc[(transport [#:in in input-port?]
                    [#:out out output-port?]
                    [#:source source authority?]
                    [#:dest dest authority?])
         transport?]{
 Constructs a @transport-tech{transport} as @racket[source] connected to
 @racket[dest] that reads data with @racket[in] and sends data with
 @racket[out]. Using this constructor is expected to be rare; most transports
 are created with procedures like @racket[tcp-connect] or tunneled over existing
 transports with procedures like @racket[tls-transport].

 The transport API does not offer any means of overriding how a transport is
 shut down, beyond the ability to make @custom-port-tech{custom ports} that
 perform special cleanup actions when closed. This is because there are two
 kinds of cleanup actions one might want to perform with a transport:

 @itemlist[
 @item{System cleanup actions that free operating system resources, such as
   releasing file descriptors associated with the input and output ports.}
 @item{Connection cleanup actions that send messages to the transport's
   destination in an attempt to negotiate a graceful connection termination,
   such as TCP's use of FIN packets.}]

 System cleanup actions are usually associated directly with a single input port
 or output port, not with the transport as a whole. As a result, it's best to
 implement system cleanup with a custom port's close procedure and rely on it
 being called when the port is closed or when the port's custodian is shut down.

 Connection cleanup actions inherently involve communication with another party
 over a network. @bold{Connection cleanup is inherently unreliable.} There is no
 way to guarantee that communication with the other party won't abrubtly
 terminate at any point. Therefore, connection cleanup is performed on a @emph{
  best effort} basis and it is unsuitable to perform connection cleanup during a
 custodian shutdown, which is expected to always succeed and involve very little
 (if any) IO.

 To properly implement connection cleanup actions in transports, connection
 cleanup logic must be encapsulated in a @disposable-tech{disposable}. This
 allows declaratively specifying how and when connection termination logic will
 execute, and reduces the complexity involved in adding timeout and early
 termination logic. See @racket[tcp-connect] for an example of a transport with
 robust and graceful connection termination.}

@deftogether[
 (@defproc[(transport-in [trans transport?]) input-port?]
   @defproc[(transport-out [trans transport?]) output-port?]
   @defproc[(transport-source [trans transport?]) authority?]
   @defproc[(transport-dest [trans transport?]) authority?])]{
 Accessors for the various components of a @transport-tech{transport} as passed in to
 the @racket[transport] constructor.}
