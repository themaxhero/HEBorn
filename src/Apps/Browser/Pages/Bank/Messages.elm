module Apps.Browser.Pages.Bank.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.Bank.Pages.Login.Messages as Login
import Apps.Browser.Pages.Bank.Pages.MainPage.Messages as MainPage
import Apps.Browser.Pages.Bank.Pages.Transfer.Messages as Transfer


type Msg
    = GlobalMsg CommonActions
    | LoginMsg Login.Msg
    | MainPageMsg MainPage.Msg
    | TransferMsg Transfer.Msg
