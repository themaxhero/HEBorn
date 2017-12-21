module Apps.Browser.Pages.Bank.Pages.Transfer.Models
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
    , account : Int
    , password : String
    , transfer : Transfer
    , error : Maybe Error
    }


type Error
    = InvalidReceiverAccount


initialTransfer : Transfer
initialTransfer =
    { bankId = Nothing
    , account = Nothing
    , value = Nothing
    }


type alias Transfer =
    { bankId : Maybe Id
    , account : Maybe String
    , value : Maybe Int
    }


initialModel : String -> Bank -> Model
initialModel url content =
    { bank = content
    , account = Nothing
    , password = Nothing
    , transfer = initialTransfer
    , error = Nothing
    }


validTransfer : Transfer -> Bool
validTransfer { bankId, account, value } =
    case ( bankId, account, value ) of
        ( Just bankId, Just account, Just value ) ->
            True

        _ ->
            False


getTransfer : Model -> Maybe Transfer
getTransfer =
    .transfer


getTitle : Model -> String
getTitle { bank } =
    bank.name ++ " Bank"
