module Setup.Pages.Helpers exposing (withHeader, getInputBorderColor, styles)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import Setup.Models exposing (Model, hasBadPages)
import Setup.Resources exposing (..)
import Css.Colors as Colors
import Css
    exposing
        ( border2
        , border3
        , px
        , color
        , solid
        , rgb
        , marginLeft
        )


withHeader : List (Html.Attribute msg) -> List (Html msg) -> Html msg
withHeader attrs content =
    node contentNode attrs <|
        flip (::) content <|
            div [] [ h1 [] [ text " D'LayDOS" ] ]


getInputBorderColor : Maybe Bool -> Attribute msg
getInputBorderColor condition =
    let
        borderBase color =
            border3 (px 1) solid color

        borderColor =
            case condition of
                Just True ->
                    [ borderBase Colors.green ]

                Just False ->
                    [ borderBase Colors.red ]

                Nothing ->
                    [ border2 (px 1) solid ]

        base =
            [ marginLeft (px 10) ]
    in
        styles (borderColor ++ base)


styles : List Css.Style -> Attribute msg
styles =
    Css.asPairs >> style
