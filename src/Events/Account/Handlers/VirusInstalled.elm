module Events.Account.Handlers.VirusInstalled exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Database exposing (virusCollected)
import Game.Account.Database.Models exposing (Virus)
import Game.Servers.Filesystem.Shared exposing (File)
import Game.Meta.Types.Network exposing (NIP)
import Events.Shared exposing (Handler)


type alias Data =
    ( File, Virus )


handler : Handler Data msg
handler toMsg =
    decodeValue virusInstalled >> Result.map toMsg
