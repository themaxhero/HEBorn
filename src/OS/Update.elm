module OS.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import OS.Header.Messages as Header
import OS.Header.Update as Header
import OS.Config exposing (..)
import OS.Messages exposing (..)
import OS.Models exposing (..)
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Update as SessionManager
import OS.Toasts.Messages as Toasts
import OS.Toasts.Update as Toasts


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Game.Data -> Msg -> Model -> UpdateResponse msg
update config data msg model =
    case msg of
        SessionManagerMsg msg ->
            onSessionManagerMsg config data msg model

        HeaderMsg msg ->
            onHeaderMsg config data msg model

        ToastsMsg msg ->
            onToastsMsg config data msg model



-- internals


onSessionManagerMsg :
    Config msg
    -> Game.Data
    -> SessionManager.Msg
    -> Model
    -> UpdateResponse msg
onSessionManagerMsg config data msg model =
    let
        config_ =
            smConfig config

        ( sm, cmd, dispatch ) =
            SessionManager.update config_ data msg <| getSessionManager model

        model_ =
            setSessionManager sm model
    in
        ( model_, cmd, dispatch )


onHeaderMsg :
    Config msg
    -> Game.Data
    -> Header.Msg
    -> Model
    -> UpdateResponse msg
onHeaderMsg config data msg model =
    Update.child
        { get = .header
        , set = (\header model -> { model | header = header })
        , toMsg = (HeaderMsg >> config.toMsg)
        , update = (Header.update data)
        }
        msg
        model


onToastsMsg : Config msg -> Game.Data -> Toasts.Msg -> Model -> UpdateResponse msg
onToastsMsg config data msg model =
    Update.child
        { get = .toasts
        , set = (\toasts model -> { model | toasts = toasts })
        , toMsg = (ToastsMsg >> config.toMsg)
        , update = (Toasts.update data)
        }
        msg
        model
