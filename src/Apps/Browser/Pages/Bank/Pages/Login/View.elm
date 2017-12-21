module Apps.Browser.Pages.Bank.Pages.Login.View exposing (view)

import Dict as Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput)
import Html.CssHelpers
import Game.Data as Game
import Apps.Browser.Pages.Bank.Pages.Login.Resources exposing (..)
import Apps.Browser.Pages.Bank.Pages.Login.Models exposing (..)
import Apps.Browser.Pages.Bank.Pages.Login.Messages exposing (Msg)


view : Game.Data -> Model -> Html Msg
view data model =
    div []
        [ div [ Header ]
            [ div []
                [ img model.bank.logo ]
            , div []
                [ text model.bank.name ]
            ]
        , span []
            [ label []
                [ text "Account Number : " ]
            , input
                [ placeholder "Account Number"
                , type_ "number"
                , onInput (toMsg UpdateLoginField)
                , value <| toString model.account
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
                , value <| toString model.password
                ]
                []
            ]
        , input
            [ type_ "button"
            , name "Sign In"
            , onSubmit (toMsg SubmitLogin)
            ]
            [ text "Sign In" ]
        ]
