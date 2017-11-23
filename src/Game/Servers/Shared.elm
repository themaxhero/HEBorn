module Game.Servers.Shared exposing (..)

import Game.Meta.Network exposing (NIP)


type alias Id =
    String


type alias EndpointAddress =
    NIP


type CId
    = GatewayCId Id
    | EndpointCId EndpointAddress
