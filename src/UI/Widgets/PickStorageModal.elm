module UI.Widgets.PickStorageModal exposing (modalPickStorage)

import Dict exposing (Dict)
import Html exposing (Html)
import UI.Widgets.Modal exposing (modal)
import Game.Servers.Models exposing (Storages)


modalPickStorage : Storages -> (Maybe String -> msg) -> Html msg
modalPickStorage storages pickResponse =
    let
        storageReducer key value acu =
            ( pickResponse <| Just key, value.name ) :: acu

        storagesBtns =
            Dict.foldr storageReducer [] storages

        btns =
            storagesBtns
                |> (::) ( pickResponse Nothing, "Cancel" )
                |> List.reverse

        cancel =
            (Just <| pickResponse Nothing)
    in
        modal (Just "Pick a storage")
            "Select where you want to save oswaldo:"
            btns
            cancel
