module Apps.Browser.Pages.Bank.Pages.Transfer.View exposing (view)

import Apps.Browser.Pages.Bank.Pages.Transfer.Models exposing (Model)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances
import Game.Account.Database.Models as Database


view : Game.Data -> Model -> Html Msg
view data model =
    let
        accounts =
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getFinances
                |> Finances.getBankAccounts

        hackedAccounts =
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getDatabase
                |> Database.getBankAccounts

        attribs =
            [ class AccountSelector, (onChange <| toMsg SetAccount) ]

        content_ =
            Dict.foldl (selectorHAccountsReducer model) [] hackedAccounts

        content =
            Dict.foldl (selectorPAccountsReducer model) ( [], True ) accounts
                |> Tuple.first
                |> flip (++) content_

        selector =
            select attribs content
    in
        div []
            [ div []
                [ span []
                    [ text "Destiny Account"
                    , selector
                    ]
                , span []
                    [ text "value : "
                    , input
                        [ type_ "number"
                        , placeholder "0.00"
                        , onInput (toMsg SetTransferValue)
                        , value <| toString model.transfer.value
                        ]
                        []
                    , input
                        [ type_ "button"
                        , name "Send"
                        , onSubmit (toMsg SubmitTransfer)
                        ]
                        [ text "Send" ]
                    ]
                ]
            ]


selectorPAccountsReducer :
    Model
    -> Finances.AccountId
    -> Finances.BankAccount
    -> ( List (Html Msg), Bool )
    -> ( List (Html Msg), Bool )
selectorPAccountsReducer model k v ( acu, first ) =
    let
        ( bankId, accountNum ) =
            k

        currentAccount =
            ( model.bank.id, account )

        str =
            bankId ++ ":" ++ (toString accountNum)

        attribs =
            [ value str ]

        attribs_ =
            if first then
                selected :: attribs
            else
                attribs
    in
        if currentAccount /= k then
            ( option attribs_ [ text str ] :: acu, False )
        else
            ( acu, False )


selectorHAccountsReducer :
    Model
    -> Database.HackedBankAccountID
    -> Database.HackedBankAccount
    -> List (Html Msg)
    -> List (Html Msg)
selectorHAccountsReducer model k v acu =
    let
        ( bankId, accountNum ) =
            k

        currentAccount =
            ( model.bank.id, account )

        str =
            bankId ++ ":" ++ (toString accountNum)

        attribs =
            [ value str ]

        attribs_ =
            attribs
    in
        if currentAccount /= k then
            option attribs_ [ text str ] :: acu
        else
            acu
