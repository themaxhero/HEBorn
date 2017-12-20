module Apps.Browser.Pages.Bank.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Model -> Html Msg
view model =
    if (model.loggedIn) then
        viewPos
    else
        viewPre


viewPos : Model -> Html Msg
viewPos model =
    div []
        [ text model.bank.name --Logo in the future
        , span []
            [ label []
                [ text "Account Number : " ]
            , input
                [ placeholder "Account Number"
                , type_ "text"
                , onInput (toMsg UpdateLoginField)
                ]
                []
            ]
        , span []
            [ label []
                [ text "Password : " ]
            , input
                [ placeholder "Password"
                , type_ "password"
                , onInput (toMsg UpdatePasswordField)
                ]
                []
            ]
        , input
            [ type_ "button"
            , name "Sign In"
            , onSubimt (toMsg SubmitLogin)
            ]
            []
        ]


viewPre : Game.Data -> Model -> Html Msg
viewPre data model =
    div []
        [ div [ class [ Header ] ]
            [ span [] [ img bank.logo, text bank.name ]
            , span [] [ text "balance : ", text (toString account.balance) ]
            ]
        , div [ class [ TransferHistory ] ]
            []
        , div [ class [ Footer ] ]
            []
        ]
