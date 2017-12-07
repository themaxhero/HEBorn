module Setup.Pages.Finish.View exposing (Config, view)

import Html exposing (..)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Setup.Resources exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.Helpers exposing (withHeader)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


type alias Config msg =
    { onNext : msg, onPrevious : msg }


view : Config msg -> Bool -> Html msg
view { onNext, onPrevious } setupOkay =
    withHeader [ class [ StepWelcome ] ]
        [ h2 [] [ text "Good bye!" ]
        , p []
            [ text "It was really good, wasn't it?" ]
        , p []
            [ text "Well.. You're ready to leave now." ]
        , p []
            [ text "Maybe you'll find someone else to help you... Maybe Black Mesa!" ]
        , p []
            [ text "What are you waiting fool? Run, Forrest, run!" ]
        , div []
            [ button [ onClick onPrevious ] [ text "BACK" ]
            , nextBtn onNext setupOkay
            ]
        ]


nextBtn : msg -> Bool -> Html msg
nextBtn onNext okay =
    let
        disable =
            disabled <| not <| okay
    in
        button [ onClick onNext, disable ] [ text "FINISH HIM" ]
