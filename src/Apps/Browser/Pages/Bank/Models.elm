module Apps.Browser.Pages.Bank.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Meta.Types.Network as Network
import Game.Web.Types as Web


type alias Model =
    { bank : Bank
    , account : Maybe String
    , password : Maybe String
    , loggedIn : Bool
    }


type alias Bank =
    { id : Servers.Id
    , name : String
    , logo : String
    }


initialModel : Model
initialModel =
    let
        initialBank =
            { id = ""
            , name = ""
            , logo = ""
            }
    in
        { bank = initialBank
        , account = Nothing
        , password = Nothing
        , loggedIn = False
        }


getTitle : Model -> String
getTitle { bank } =
    bank.name ++ " Bank"
