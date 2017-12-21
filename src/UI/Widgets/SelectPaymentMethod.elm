module UI.Widgets.SelectPaymentMethod exposing (modalSelectPaymentMethod)

import Dict exposing (Dict)
import Html exposing (Html)
import UI.Widgets.Modal exposing (modal)
import Game.Account.Finances.Models exposing (BankAccounts)


modalSelectPaymentMethod : BankAccounts -> msg -> Html msg
modalSelectPaymentMethod accounts payValue pay =
    let
        accountsReducer key value acu =
            ( pay <| Just ( key, payValue ), accountLabel key ) :: acu

        accountBtns =
            Dict.foldl accountsReducer [] accounts

        btns =
            accountBtns
                |> (::) ( pay Nothing, "Cancel" )

        cancel =
            (Just <| pay Nothing)
    in
        modal
            (Just "Select Payment Method")
            "Select a Bank Account : "
            btns
            cancel
