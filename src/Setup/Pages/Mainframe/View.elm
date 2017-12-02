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
import Setup.Pages.Helpers exposing (withHeader)
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Game.Model -> Model -> Html msg
view { toMsg, onNext, onPrevious } game model =
    let
        errorStyle =
            styles
                [ color (rgb 255 0 0)
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
                    , nextBtn onNext toMsg model
                    ]
                ]
            ]


hostnameInput : (List Settings -> msg) -> (Msg -> msg) -> Model -> Html msg
hostnameInput onNext toMsg model =
    let
        hostName =
            Maybe.withDefault "" (model.hostname)

        statusAttr =
            if okayCondition model then
                styles
                    [ border3 (px 1) solid (rgb 0 255 0)
                    , marginLeft (px 10)
                    ]
            else if errorCondition model then
                styles
                    [ border3 (px 1) solid (rgb 255 0 0)
                    , marginLeft (px 10)
                    ]
            else
                styles [ border2 (px 1) solid, marginLeft (px 10) ]

        attrs =
            [ onInput <| Mainframe >> toMsg --
            , onBlur <| toMsg Validate
            , placeholder "hostname"
            , value hostName
            , statusAttr
            ]
    in
        input
            attrs
            []


nextBtn : (List Settings -> msg) -> (Msg -> msg) -> Model -> Html msg
nextBtn onNext toMsg model =
    let
        attrs =
            [ type_ "submit", value "NEXT" ]
    in
        input attrs []


styles : List Css.Style -> Attribute msg
styles =
    Css.asPairs >> style


okayCondition : Model -> Bool
okayCondition model =
    (isOkay model) && not (hasErrorMsg model)


errorCondition : Model -> Bool
errorCondition model =
    (hasErrorMsg model) && not (isOkay model)
