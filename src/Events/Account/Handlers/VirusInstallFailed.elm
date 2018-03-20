module Events.Account.Handlers.VirusInstallFailed exposing (Data, handler)

import Json.Decode exposing (decodeValue, string)
import Decoders.Database exposing (virusCollected)
import Game.Account.Database.Models exposing (Virus)
import Game.Servers.Filesystem.Shared exposing (File)
import Game.Meta.Types.Network exposing (NIP)
import Events.Shared exposing (Handler)


type alias Data =
    String


handler : Handler Data msg
handler toMsg =
    decodeValue string >> Result.map toMsg
