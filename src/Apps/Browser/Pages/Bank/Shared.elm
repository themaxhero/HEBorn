module Apps.Browser.Pages.Bank.Shared exposing (..)

import Game.Meta.Types.Network as Network
import Game.Web.Types as Web
import Game.Servers.Shared exposing (Id)


type alias Bank =
    { id : Id
    , name : String
    , logo : String
    }
