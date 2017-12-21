module Apps.Browser.Pages.Bank.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        )

import Game.Meta.Types.Network as Network
import Game.Web.Types as Web
import Game.Servers.Shared exposing (Id)
import Apps.Browser.Pages.Bank.Pages.Login.Models as Login
import Apps.Browser.Pages.Bank.Pages.MainPage.Models as Main
import Apps.Browser.Pages.Bank.Pages.Transfer.Models as Transfer
import Apps.Browser.Pages.Bank.Shared exposing (Bank)


type alias Model =
    { bank : Bank
    , login : Login.Model
    , main : Main.Model
    , transfer : Transfer.Model
    , account : Maybe Int
    , page : Page
    , url : String
    }


type Page
    = LoginPage
    | MainPage
    | TransferPage


initialModel : String -> Bank -> Model
initialModel url bank =
    { bank = bank
    , login = Login.initialModel bank
    , main = Main.initialModel bank
    , transfer = Transfer.initialModel bank
    , account = Nothing
    , page = LoginPage
    , url = url
    }


getTitle : Model -> String
getTitle { bank } =
    bank.name ++ " Bank"
