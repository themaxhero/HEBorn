module Setup.Subscriptions exposing (subscriptions)

import Game.Models as Game
import Setup.Models exposing (..)
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Setup.Pages.Configs as Configs
import Setup.Pages.PickLocation.Subscriptions as PickLocation


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        ( Just (PickLocationModel model), _ ) ->
            PickLocation.subscriptions Configs.pickLocation model

        _ ->
            Sub.none
