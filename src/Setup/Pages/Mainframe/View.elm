module Setup.Pages.Mainframe.View exposing (view)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes
    exposing
        ( placeholder
        , value
        , disabled
        , style
        , type_
        , name
        )
import Html.CssHelpers
import Css
    exposing
        ( border2
        , border3
        , px
        , color
        , solid
        , rgb
        , paddingLeft
        , marginLeft
        )
import Game.Models as Game
import Json.Decode as Decode
import Setup.Resources exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.Helpers exposing (withHeader, getInputBorderColor, styles)
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Css.Colors as Colors
import Setup.Pages.Mainframe.Config exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Game.Model -> Model -> Html msg
view { toMsg, onNext, onPrevious } game model =
    let
        errorStyle =
            styles
                [ color Colors.red
                , paddingLeft (px 5)
                ]

        errorToString =
            case model.error of
                Just InvalidHostname ->
                    "Hostname is invalid"

                _ ->
                    ""

        formAttribs =
            if okayCondition model then
                [ onSubmit <| goNext ]
            else
                [ onSubmit <| toMsg Validate ]

        goNext =
            onNext <| settings model

        error =
            if hasErrorMsg model then
                span [ errorStyle ] [ text errorToString ]
            else
                span [] [ text " " ]
    in
        withHeader [ class [ StepWelcome ] ]
            [ div []
                [ h2 []
                    [ text "Initial server name:" ]
                ]
            , Html.form formAttribs
                [ hostnameInput onNext toMsg model
                , error
                , div []
                    [ input [ type_ "button", value "BACK", onClick onPrevious ] []
                    , nextBtn model
                    ]
                ]
            ]


hostnameInput : (List Settings -> msg) -> (Msg -> msg) -> Model -> Html msg
hostnameInput onNext toMsg model =
    let
        hostName =
            Maybe.withDefault "" (model.hostname)

        attrs =
            [ onInput <| Mainframe >> toMsg
            , onBlur <| toMsg Validate
            , placeholder "hostname"
            , value hostName
            , getInputBorderColor <| inputColorCondition model
            ]
    in
        input
            attrs
            []


nextBtn : Model -> Html msg
nextBtn model =
    let
        attrs =
            [ type_ "submit", value "NEXT" ]
    in
        input attrs []
