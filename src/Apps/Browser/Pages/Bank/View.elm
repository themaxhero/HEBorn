module Apps.Browser.Pages.Bank.View exposing (view)

import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput)
import Html.CssHelpers
import Utils.Html.Events exposing (onChange)
import Game.Data as Game
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Bank.Resources exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)
import Apps.Browser.Pages.Bank.Pages.Login.View as Login
import Apps.Browser.Pages.Bank.Pages.Login.Messages as Login
import Apps.Browser.Pages.Bank.Pages.MainPage.View as Main
import Apps.Browser.Pages.Bank.Pages.MainPage.Messages as Main
import Apps.Browser.Pages.Bank.Pages.Transfer.View as Transfer
import Apps.Browser.Pages.Bank.Pages.Transfer.Messages as Transfer


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view model =
    case model.page of
        LoginPage ->
            Login.view data model.loginModel
                |> Html.map LoginMsg

        MainPage ->
            Main.view data model.mainModel
                |> Html.map MainPageMsg

        TransferPage ->
            Transfer.view data model.transferModel
                |> Html.map TransferMsg

        _ ->
            view404


view404 : Html Msg
view404 =
    div []
        [ div [] [ "Error 404" ]
        , div [] [ "Page not Found" ]
        ]
