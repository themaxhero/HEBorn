module Apps.Browser.Pages.Bank.Pages.Transfer.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Pages.Transfer.Models exposing (..)
import Apps.Browser.Pages.Bank.Pages.Transfer.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        SubmitTransfer ->
            onSubmitTransfer data model

        SetTransferAccount account ->
            onSetTransferAccount data account model

        SetTransferValue value ->
            onSetTransferValue data value model

        _ ->
            Update.fromModel model


onSubmitTransfer : Game.Data -> Model -> UpdateResponse
onSubmitTransfer data model =
    let
        transfer =
            model.transfer

        game =
            data
                |> Game.getGame

        cmd =
            Transfer.request
                model.bank.id
                model.account
                transfer.bankId
                transfer.account
                transfer.value
                game
    in
        if validTransfer model.transfer then
            ( model, cmd, Dispatch.none )
        else
            Update.fromModel model


onSetTransferAccount : Game.Data -> String -> Model -> UpdateResponse
onSetTransferAccount data account model =
    let
        getAccount accountNum =
            case toInt accountNum of
                Ok value ->
                    Just value

                Err _ ->
                    Nothing

        transfer =
            case String.split ":" account of
                [ bankId, accountNum ] ->
                    case model.transfer of
                        Just transfer ->
                            Just
                                { transfer
                                    | bankId = Just bankId
                                    , account = getAccount accountNum
                                }

                        Nothing ->
                            { bankId = Just bankId
                            , account = getAccount accountNum
                            , value = Nothing
                            }

                _ ->
                    model.transfer

        model_ =
            { model | transfer = transfer }
    in
        Update.fromModel model_


onSetTransferValue : Game.Data -> String -> Model -> UpdateResponse
onSetTransferValue data value model =
    let
        transfer =
            case model.transfer of
                Just transfer ->
                    { transfer | value = getValue }

                Nothing ->
                    { bankId = Nothing
                    , account = Nothing
                    , value = getValue
                    }

        getValue =
            case toInt value of
                Ok value ->
                    Just value

                Err _ ->
                    Nothing

        model_ =
            { model | transfer = transfer }
    in
        Update.fromModel model_
