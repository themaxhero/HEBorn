module Apps.Browser.Pages.Bank.Pages.MainPage.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Time exposing (Time)
import Game.Meta.Types.Network as Network
import Game.Web.Types as Web
import Game.Servers.Shared exposing (Id)
import Apps.Browser.Pages.Bank.Shared exposing (Bank)


type alias Model =
    { bank : Bank
    , account : Int
    , transferHistory : TransferHistory
    }


type alias TransferHistory =
    Dict ( Time, Int ) TransferHistoryEntry


type alias TransferHistoryEntry =
    { value : Int
    , timestamp : Time
    }


initialModel : Bank -> Model
initialModel bank =
    { bank = bank
    , account = Nothing
    , password = Nothing
    , error = Nothing
    }


getTitle : Model -> String
getTitle { bank } =
    bank.name ++ " Bank"
