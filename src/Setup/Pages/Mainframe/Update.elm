module Setup.Pages.Mainframe.Update exposing (update)

import Json.Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Update as Update
import Utils.Maybe as Maybe
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Requests.Check as Check
import Game.Account.Models as Account


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Game.Model -> Msg -> Model -> UpdateResponse msg
update config game msg model =
    case msg of
        Mainframe str ->
            onMainframe str model

        Validate ->
            onValidate config game model

        Error str ->
            case str of
                "hostname_invalid" ->
                    let
                        model_ =
                            { model | error = InvalidHostname }
                    in
                        Update.fromModel model_

                _ ->
                    let
                        model_ =
                            { model | error = None }
                    in
                        Update.fromModel model_

        Checked True ->
            Update.fromModel <| setOkay model

        Checked False ->
            Update.fromModel model


onMainframe : String -> Model -> UpdateResponse msg
onMainframe str model =
    Update.fromModel <| setMainframeName str model


onValidate : Config msg -> Game.Model -> Model -> UpdateResponse msg
onValidate { toMsg } game model =
    let
        mainframe =
            game
                |> Game.getAccount
                |> Account.getMainframe

        hostname =
            getHostname model

        cmd =
            case Maybe.uncurry mainframe hostname of
                Just ( cid, name ) ->
                    Check.serverName
                        (handleMsg >> toMsg)
                        name
                        cid
                        game

                Nothing ->
                    Cmd.none
    in
        ( model, cmd, Dispatch.none )


handleMsg : Check.MsgCheck -> Msg
handleMsg msg =
    case msg of
        Check.Valid bool ->
            Checked bool

        Check.Invalid str ->
            Error (Maybe.withDefault "" str)
