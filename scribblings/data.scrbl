#lang scribble/manual
@(require "base.rkt")

@title{Networking Data Structures}
@defmodule[net2/data]

The @racketmodname[net2] library defines several data structures related to
networking, as well as validating conversions to and from strings. Many of these
data types are specified by Request for Comments (RFC) documents published by
the Internet Engineering Task Force (IETF); references to appropriate
specifications are included in the documentation of each data structure.

To understand these types more deeply, understand that many reside in a
centrally managed globally unique namespace defined and operated by the Internet
Assigned Numbers Authority (IANA). The IANA may delegate assignment of
subsections of a namespace to other organizations, which may delegate them
further. This chained delegation of namespace responsibility defines a
@fed-ns-tech[#:definition? #t]{federated namespace}. DNS names serve as a
classic example of such a namespace.

@section{IP Addresses}

@defstruct*[ip4 ([bytes (bytes/c 4)]) #:transparent]{
 An IPv4 address.}

@defstruct*[ip6 ([bytes (bytes/c 16)]) #:transparent]{
 An IPv6 address.}

@section{Abstract Registered Names}

@defstruct*[reg-name () #:transparent]{
 Supertype of all @reg-name-tech[#:definition? #t]{registered names}: names that
 are centrally managed according to some publicly known name registry. Subtypes
 of @racket[reg-name] typically specify what registry is used and how to
 register names, as well as how to resolve a registered name to a host if
 possible. This name-to-host resolution process is often referred to as a
 @lookup-tech[#:definition? #t]{name lookup}.

 Note that IP addresses are not considered registered names by this definition
 because their name-to-host mapping is an inherent physical property of the
 Internet's network topology and the IP protocol itself. Put more simply, an IP
 address isn't a name for an Internet host: it's the @emph{definition} of a
 host.

 Registered names are used in URIs and @authority-tech{authorities} to avoid
 name collisions for global identifiers. Frequently the registry for a name
 will allow extension and delegation with a @fed-ns-tech{federated namespace}.

 All registered names SHOULD obey the syntax rules for well-formed DNS
 addresses. Additionally, names that depend on the resolver's context (such as
 the "localhost" DNS address) SHOULD be distinguishable from globally-scoped
 names without requiring clients perform a @lookup-tech{name lookup}. Designers
 of new globally-scoped registered name systems are encouraged to reuse the
 Special Use Domain Names of DNS specified in RFC 6761, ideally with reasonably
 equivalent semantics.

 Currently, the only subtypes of @racket[reg-name] are the @racket[dns] and
 @racket[unix-socket-name] types.}

@section{DNS Names}

@defstruct*[(dns reg-name) ([labels (listof dns-label?)])
            #:transparent]{
 A Domain Name System @reg-name-tech{registered name} consisting of
 @racket[labels] as defined by RFC 952, RFC 1034, RFC 1035, and RFC 1123 Section
 2. In addition to the length restrictions of @racket[dns-label?], the total
 length of a DNS name must not exceed 255 bytes @emph{including one byte for a
  length header between labels.}

 If the last element of @racket[labels] is @racket[dns-root], the name is @emph{
  fully qualified}. Otherwise, the domain name is @emph{partially qualified} and
 is typically resolved relative to either the root domain or relative to a
 domain in a locally configured search list.}

@defproc[(dns-label? [v any/c]) boolean?]{
 Implies @racket[(bytes? v)]. Returns @racket[#t] when @racket[v] is a valid
 DNS label. Labels may consist of zero to 63 bytes with no restrictions on what
 bytes are allowed. However, according to the RFCs mentioned in @racket[dns],
 labels that are equal when compared case-insensitively as Latin-1 strings are
 considered identical. When rendered, labels are typically displayed as
 strings.}

@defthing[dns-root dns-label? #""]{
 The root DNS nameserver, represented by an empty label. See @racket[dns] for a
 discussion on the root nameserver and the difference between fully and
 partially qualified names.}

@section{UNIX Socket Names}

@defstruct*[(unix-socket-name reg-name)
            ([path (and/c unix-socket-path? complete-path?)]) #:transparent]{
 A @reg-name-tech{registered name} corresponding to a host that can be
 communicated with via the UNIX domain socket @racket[path]. Note that all
 domain socket communication is inherently between processes on the same
 machine and involves no network access. The machine in question must be running
 a POSIX-compliant operating system and abstract socket names (as used in Linux)
 are not supported. Due to the use of registered names in URIs, a few more
 restrictions beyond those implied by @racket[complete-path?] and
 @racket[unix-socket-path?] must be satisfied:

 @itemlist[
 @item{Only absolute paths are allowed, to ensure socket names passed between
   processes in URIs cannot be misinterpreted due to differences in the current
   directory of those processes.}
 @item{Alphabetic characters in @racket[path] must be lowercase, as the generic
   syntax of URIs specifies that all registered names are compared case
   insensitively.}
 @item{The result of applying @racket[unix-socket-name->string] to the resulting
   name must not exceed 255 characters. Due to the 108 byte limit of POSIX
   socket paths this is unlikely to occur, but in the presence of percent
   encoding a long @racket[path] with many unusual bytes may exceed this limit.}
 @item{The result of @racket[(simplify-path path)] should be identical to
   @racket[path], to avoid representing the same socket with multiple different
   names. Additionally, following symlinks prior to path construction helps
   avoid processes unintentionally interpreting the same path differently.}]}

@section{Authorities}

@defstruct*[authority ([host (or/c ip6? ip4? reg-name?)] [port port-number?])
            #:transparent]{
 Structure type of an @authority-tech[#:definition? #t]{authority}, as defined
 in RFC 3986. An authority is a hierarchical representation of some sort of
 naming authority, which establishes who has the right to @emph{respond
  authoritatively} for requests to that authority's namespace. For example, an
 authority composed of an IP address and a port number establishes whatever
 program is listening for connections to that port on the machine reachable at
 that IP address as a naming authority.

 Authorities are a component of the generic syntax of URIs, and are used in URIs
 to define how to take a URI and establish who to talk to for authoritative
 information about the resource identified by the URI. Note that URIs include a
 scheme component that establishes what protocol to use when communicating with
 an authority.

 Currently, including identifying user info in authorites (see RFC 3986 Section
 3.2.1) is not supported due to historically widespread security problems and a
 lack of immediate use cases.}

@section{URIs}

@section{Contract Utilities}

@defproc[(bytes/c [n exact-nonnegative-integer?]) flat-contract?]{
 Returns a flat contract that recognizes immutable bytestrings of length
 @racket[n].}
