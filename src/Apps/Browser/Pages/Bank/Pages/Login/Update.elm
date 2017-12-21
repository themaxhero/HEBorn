module Apps.Browser.Pages.Bank.Pages.Login.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Pages.Login.Models exposing (..)
import Apps.Browser.Pages.Bank.Pages.Login.Messages exposing (..)
import Apps.Browser.Pages.Bank.Pages.Requests.Login as Login


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        UpdateLoginField str ->
            onUpdateLoginField data str model

        UpdatePasswordField str ->
            onUpdatePasswordField data str model

        SubmitLogin ->
            onSubmitLogin data model


onUpdateLoginField : Game.Data -> String -> Model -> UpdateResponse
onUpdateLoginField data str model =
    let
        getAccount =
            case toInt str of
                Ok value ->
                    Just value

                Err _ ->
                    Nothing

        model_ =
            { model | account = getAccount }
    in
        Update.fromModel model_


onUpdatePasswordField : Game.Data -> String -> Model -> UpdateResponse
onUpdatePasswordField data str model =
    let
        model_ =
            { model | password = Just str }
    in
        Update.fromModel model_


onSubmitLogin : Config msg -> Game.Data -> Model -> UpdateResponse
onSubmitLogin data model =
    let
        ( bank, account, password ) =
            ( model.bank.id, model.account, model.password )

        game =
            data
                |> Game.getGame

        cmd =
            Login.request bank account password game
    in
        ( model, cmd, Dispatch.none )
