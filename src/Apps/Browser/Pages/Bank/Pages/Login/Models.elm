module Apps.Browser.Pages.Bank.Pages.Login.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Meta.Types.Network as Network
import Game.Web.Types as Web
import Game.Servers.Shared exposing (Id)
import Apps.Browser.Pages.Bank.Shared exposing (Bank)


type alias Model =
    { bank : Bank
    , account : Maybe Int
    , password : Maybe String
    , error : Maybe Error
    }


type Error
    = InvalidAccount


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
