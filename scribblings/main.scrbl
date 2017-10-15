#lang scribble/manual

@(require "base.rkt")

@title{Net2: Evolved Networking Libraries}
@defmodule[net2 #:packages ("net2")]
@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

This package provides new implementations of much of the functionality of the
@racketmodname[net] libraries. In addition, parts of these implementations are
broken down into generic components that can be reused more easily in other
protocols.

@include-section["data.scrbl"]
