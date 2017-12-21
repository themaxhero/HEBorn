module Apps.Browser.Pages.Bank.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)
import Apps.Browser.Pages.Bank.Pages.Login.Update as Login
import Apps.Browser.Pages.Bank.Pages.Login.Messages as Login
import Apps.Browser.Pages.Bank.Pages.Transfer.Update as Transfer
import Apps.Browser.Pages.Bank.Pages.Transfer.Messages as Transfer
import Apps.Browser.Pages.Bank.Pages.MainPage.Update as MainPage
import Apps.Browser.Pages.Bank.Pages.MainPage.Messages as MainPage
import Apps.Browser.Pages.Bank.Requests.Transfer as Transfer


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        GlobalMsg _ ->
            onGlobalMsg data model

        LoginMsg _ ->
            onLoginMsg data msg model

        MainPageMsg _ ->
            onMainPageMsg data msg model

        TransferMsg _ ->
            onTransferMsg data msg model


onGlobalMsg : Game.Data -> Model -> UpdateResponse
onGlobalMsg data model =
    -- Treated in Browser.Update
    Update.fromModel model


onLoginMsg : Game.Data -> Msg -> Model -> UpdateResponse
onLoginMsg data msg model =
    case msg of
        LoginMsg (Login.UpdateRouter { account }) ->
            let
                ( login, cmd, dispatch ) =
                    Login.update data msg model.login

                model_ =
                    { model | account = account, page = MainPage }
            in
                Update.fromModel model_

        LoginMsg msg ->
            let
                ( login, cmd, dispatch ) =
                    Login.update data msg model.login

                model_ =
                    { model | login = login }
            in
                Update.fromModel model_


onMainPageMsg : Game.Data -> Msg -> Model -> UpdateResponse
onMainPageMsg data msg model =
    case msg of
        MainPageMsg MainPage.GoToTransfer ->
            let
                model_ =
                    { model | page = TransferPage }
            in
                Update.fromModel model_

        MainPageMsg MainPage.Logout ->
            let
                model_ =
                    initialModel model.url model.bank
            in
                Update.fromModel model_

        MainPageMsg msg ->
            let
                ( main, cmd, dispatch ) =
                    MainPage.update data msg model.main

                model_ =
                    { model | main = main }
            in
                Update.fromModel model_


onTransferMsg : Game.Data -> Msg -> Model -> UpdateResponse
onTransferMsg data msg model =
    case msg of
        TransferMsg Transfer.GoToMain ->
            let
                ( transfer, cmd, dispatch ) =
                    Transfer.update data msg model.transfer

                model_ =
                    { model | transfer = transfer, page = MainPage }
            in
                Update.fromModel model_

        TransferMsg msg ->
            let
                ( transfer, cmd, dispatch ) =
                    Transfer.update data msg model.transfer

                model_ =
                    { model | transfer = transfer }
            in
                Update.fromModel model_
