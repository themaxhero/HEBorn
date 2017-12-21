module UI.Widgets.Modal
    exposing
        ( modal
        , modalOkCancel
        , modalNode
        , overlayNode
        )

import UI.Widgets.CustomSelect exposing (customSelect)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, node, div, button, text, h3, span)
import Html.CssHelpers
import Html.Events exposing (onClick)
import OS.SessionManager.WindowManager.Resources exposing (..)


-- example usage: `modal "Are you sure?" []`


wmClass : List class -> Attribute msg
wmClass =
    .class <| Html.CssHelpers.withNamespace prefix


modalOkCancel : Maybe String -> String -> msg -> msg -> Html msg
modalOkCancel title content ok cancel =
    modal title content [ ( ok, "Ok" ), ( cancel, "Cancel" ) ] Nothing


modal : Maybe String -> String -> List ( msg, String ) -> Maybe msg -> Html msg
modal title content buttons fallback =
    let
        buttons_ =
            let
                reducer ( action, content ) buttons =
                    button
                        [ onClick action ]
                        [ text content ]
                        :: buttons
            in
                node btnsNode [] <|
                    List.foldr reducer [] buttons

        msg =
            [ span [] [ text content ] ]

        main =
            case title of
                Just title ->
                    h3 [] [ text title ] :: msg

                Nothing ->
                    msg

        content_ =
            node contentNode
                []
                [ node msgNode [] main
                , buttons_
                ]
                |> List.singleton
                |> node containerNode []

        root =
            node modalNode [] [ overlay fallback, content_ ]
    in
        root


accountLabel : AccountId -> BankAccount -> Html msg
accountLabel id account =
    let
        name =
            account.name

        number =
            toString <| Tuple.second id

        balance =
            toMoney (account.balance)
    in
        name ++ " : (" ++ number ++ ")" ++ " : USD " ++ balance


overlay : Maybe msg -> Html msg
overlay fallback =
    let
        attr =
            fallback
                |> Maybe.map (onClick >> List.singleton)
                |> Maybe.withDefault []
    in
        node overlayNode attr []


modalNode : String
modalNode =
    "modal"


btnsNode : String
btnsNode =
    "btns"


contentNode : String
contentNode =
    "content"


containerNode : String
containerNode =
    "container"


msgNode : String
msgNode =
    "msg"


overlayNode : String
overlayNode =
    "overlay"
