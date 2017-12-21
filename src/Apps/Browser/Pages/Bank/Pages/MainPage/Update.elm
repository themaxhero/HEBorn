module Apps.Browser.Pages.Bank.Pages.MainPage.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Pages.MainPage.Models exposing (..)
import Apps.Browser.Pages.Bank.Pages.MainPage.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        Logout ->
            Update.fromModel model

        GoToTransfer ->
            Update.fromModel model
