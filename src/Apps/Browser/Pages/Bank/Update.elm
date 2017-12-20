module Apps.Browser.Pages.Bank.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        GlobalMsg _ ->
            -- Treated in Browser.Update
            Update.fromModel model

        UpdateLoginField str ->
            onUpdateLoginField data str model

        UpdatePasswordField str ->
            onUpdatePasswordField data str model

        SubmitLogin ->
            onSubmitLogin data model


onUpdateLoginField : Game.Data -> String -> Model -> UpdateResponse
onUpdateLoginField data str model =
    let
        model_ =
            { model | account = str }
    in
        Update.fromModel model_


onUpdatePasswordField : Game.Data -> String -> Model -> UpdateResponse
onUpdatePasswordField data str model =
    let
        model_ =
            { model | password = str }
    in
        Update.fromModel model_


onSubmitLogin : Game.Data -> Model -> UpdateResponse
onSubmitLogin data model =
    let
        cmd =
            Login.request model.account model.password data
    in
        ( model, cmd, Dispatch.none )
