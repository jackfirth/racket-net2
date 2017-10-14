# Roadmap For the `net2` Project

This document roughly describes the goals and non-goals of the `net2` package.
In general, `net2` aims to achieve three things:

1. Define a generic representation of a network connection and provide ways to
   operate on connections generically, including opening in-memory connections
   between named Racket threads
2. Define generic patterns for sending and receiving messages with URLs
3. Implement useful real-world protocols including HTTP2 and JSON-RPC

## Primary Directive

The `net2` package will offer a single unified interface for establishing
*transports* between two *agents*, typically over the Internet, where at least
one of the agents is implemented in Racket. Both transports and agents are
abstract concepts that come in many forms. However, some properties are expected
to be common across all specializations:

- An *agent* is some party associated with a particular URL authority, as
  defined in RFC 3986. This could be an IP address and port number, but it also
  includes other kinds of extensible "registered names" as defined in the RFC.
  The `net2` package will include datatype definitions and default
  implementations of the following registered names:
  - IPv4 addresses
  - IPv6 addresses
  - DNS addresses
  - UNIX domain socket paths, to enable low-overhead machine-local
    communication between processes.
  - Racket Transport Addresses, a new addressing protocol defined in `net2` that
    allows addressing different parties within a single Racket VM or within a
    network of Racket VMs where addresses are independent of the number of
    machines, processes, or OS threads (not Racket green threads) that make up
    the VM network
- A *transport* is a combination of a Racket input port, a Racket output port, a
  URL authority representing the agent capable of writing and reading bytes to
  and from those ports, and a URL authority representing where the output port
  sends bytes to and where the input port reads bytes from. Additionally, a
  transport must provide a *reliable*, *buffered*, and *ordered* means of
  sending and receiving those bytes, where these terms have the same meaning as
  in TCP connections. Note that a transport need not guarantee failures won't
  occur; a transport's ports may close or fail to send or receive any additional
  bytes at arbitrary times without warning.

There are two ways of creating transports: an agent requesting that another
authority's agent open a new transport between them, or by an agent claiming an
authority and waiting for some other agent to request opening a transport. For
this, `net2` will offer the *connector* and *listener* abstractions:

- A *connector* is a means for an agent to specify an authority and initiate a
  transport with the agent associated with that authority. Connecting to
  non-Racket-implemented agents is not only supported; it must use the same
  interfaces as connecting to a Racket agent to allow implementations to change
  without breaking authority addressing.
- A *listener* is a means for Racket code to claim association with an
  authority and accept connections from other agents attempting to connect to
  that authority.

The `net2` package will include implementations of both connectors and listeners
for the following kinds of transports:

- TCP connections to IPv4, IPv6, and DNS authorities
- UNIX domain sockets to socket paths
- Connections to Racket Transport Addresses
- TLS-encrypted tunnels with hostname verification over arbitrary transports

## Secondary Directive

Atop the framework defined in the Primary Directive, the `net2` package will
provide abstractions for building higher-level protocols atop transports in
terms of URIs with arbitrary schemes. This includes defining a new `uri` struct
to replace the existing one in `net/url`, as the current struct definition is
too HTTP specific and does not always parse other kinds of URIs correctly. To
create protocols in terms of URIs, `net2` will provide the following:

- *codecs*, for taking structured data and allowing streamed reads and writes of
  that data in smaller units, typically bytes. Codecs should *compose*, so that
  one codec may define how to, for example, turn a request data structure into a
  stream of smaller "frames" while relying on some other codec to define how to
  turn a frame into a byte stream. Codecs will not assume they are being used to
  read and write with ports.
- *messengers*, for taking codecs and a transport and providing a way to read
  and write "messages" (structured data) to the transport with the codecs. Reads
  and writes should be buffered at the message level, with concurrent reads and
  writes allowed. Messengers are for arbitrary two-way communication instead of
  client-server communication, allowing listening agents to send messages
  unprompted and clients to listen for messages before sending any messages
  themselves.
- *clients* and *servers*, which build atop messengers and a named protocol
  scheme to provide request-response handling to URLs in terms of ordinary
  Racket functions. Common message transport patterns like request pipelining
  and stream multiplexing should be implemented generically at this level.
  Reusable proxy logic also belongs here. Note the use of the term "proxy"
  instead of "middleware" - the former implies three agents with different
  authorities, while the latter implies intercepting code run in either the
  client or server agent. Multiple simple agents are preferred to a single
  complex agents, as they provide better encapsulation and isolation when
  dealing with distributed state. The use of Racket Transport Addresses should
  allow a single process to many in-memory proxies, avoiding the deployment
  complexity associated with trying to connect to proxies over standard IP
  networks.

## Tertiary Directive

With implementations of the above abstract networking concepts, the `net2`
package will provide implementations of some protocols, most importantly HTTP2.
Additionally, existing implementations of useful protocols may be wrapped or
ported to work with transports. Protocols to implement include:

- HTTP/1.0, HTTP/1.1, and HTTP2
- JSON-RPC
- XML-RPC
- STOMP

Primary focus will be given to HTTP, particularly HTTP2.

## Future Work

This still isn't enough to make HTTP as easy to work with as it could be. Future
work may include an abstraction for a *resource* that one can call HTTP methods
like GET and PUT on, with responses converted to Racket datatypes. Links between
resources should be included as a first-class concept, to make REST-ful
hypermedia APIs frictionless enough to use in clients that servers can implement
them in terms of many small and generic proxy components.

## Non Goals

A configuration library or framework will not be included, and `net2` will not
assume the existence of any particular config mechanism such as environment
variables, command line flags, or config files. Parameters with default values
that are lazily initialized from environment variables *may* be acceptable on a
case by case basis.

Performance will not be a focus of `net2`, but `net2` will try to avoid limiting
performance through architecture decisions. Racket ports, especially chains of
in-memory ports, will likely be the biggest drain on performance.

Testing utilities will not be included in `net2` at this stage. The architecture
of `net2` is designed to make testing frictionless, particularly by allowing
services that would normally communicate over TCP to communicate with in-memory
pipes from a single Racket process. A separate `net2-testing` package could add
support for more advanced testing features like simulating high-latency
connections or testing hypermedia state transitions.

The Racket Transport Address protocol will be designed to *accommodate*
communication across both local and distributed places, but not more than that.
In particular, a framework for creating a distributed network of Racket VMs will
absolutely not be provided. However, the `net2` protocol will provide a means to
override how addresses are interpreted to ensure such a framework could be
implemented in the future. Integration with Marketplace, Syndicate, and similar
Racket packages modeling distributed execution should be considered, but little
more than that is expected.

Connectionless communication including UDP will not be implemented in `net2`.
Codecs may be written generically enough to allow reuse, but pretty much
everything else will assume a reliable ordered transport for communication.

Not all protocols in the existing `net` collection will be supported, although
any protocols implemented in terms of input ports and output ports representing
TCP connections should be easy to implement atop `net2`.

Resource management strategies including connection pooling will explicitly
*not* be implemented in `net2`. Instead, `net2` will rely on the `disposable`
package to provide generic resource management patterns. Some interfaces in
`net2` may rely on disposables, effectively making `disposable` an API-level
dependency of `net2`.

Error handling, supervision, and timeout logic will *not* be implemented in
`net2`. Other packages are expected to supply generic logic that can be composed
with `net2` by clients, such as retryers from the `retry` package. Note that
the disposables API includes many ways of ensuring resources are gracefully
reclaimed in the event of errors.

Semantic Web concepts and technologies such as RDF and JSON-LD will not be
implemented by `net2`. However, hopefully the hypothetical high-level HTTP API
discussed in Future Work will not conflict with any Semantic Web
implementations. Additionally, the `net2` package's definitions of types like
URIs that are important to Semantic Web concepts will be very carefully designed
to ensure maximum compliance with relevant RFC and Best Current Practice (BCP)
standards.

Codecs overlap a bit with parser combinators, traversals, lenses, and
isomorphisms; this may be resolved in the future once more of the API is
designed. However, codecs as provided by `net2` will *not* be defined in terms
of pure functions on lazy streams. This is to avoid both performance overhead
and conceptual mismatches when using codecs with Racket ports, which act as
imperatively iterable generic sequences of bytes.

Dataflow-based distributed programming such as might be used in massively
parallel stream pipelines will not be implemented in `net2`. That work is left
to other packages that should be built on top of `net2`.
