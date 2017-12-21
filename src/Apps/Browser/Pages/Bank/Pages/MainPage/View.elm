module Apps.Browser.Pages.Bank.Pages.MainPage.View exposing (view)

import Apps.Browser.Pages.Bank.Pages.MainPage.Models exposing (Model)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances
import Game.Account.Finances.Shared exposing (toMoney)
import Apps.Browser.Pages.Bank.Pages.MainPage.Messages exposing (Msg)


view : Game.Data -> Model -> Html Msg
view data model =
    let
        account =
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getFinances
                |> Finances.getBankAccounts
                |> Dict.get ( model.bank.id, accountNum )

        accountNum =
            case toInt model.account of
                Ok number ->
                    number

                Err ->
                    0
    in
        div []
            [ div [ class [ Header ] ]
                [ span [] [ img model.bank.logo, text model.bank.name ]
                , span [] [ text "balance : ", text (toMoney account.balance) ]
                , span [] [ button [ onClick Logout ] [ text "Logout" ] ]
                ]
            , div [ class [ TransferHistory ] ]
                renderTransferHistory
            , div [ class [ Transfer ] ]
                [ button [ onClick GoToTransfer ] [ text "Transfer" ] ]
            , div [ class [ Footer ] ]
                []
            ]


renderTransferHistory : List (Html Msg)
renderTransferHistory =
    []
