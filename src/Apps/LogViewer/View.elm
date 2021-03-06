module Apps.LogViewer.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Utils.Html exposing (spacer)
import UI.ToString exposing (timestampToFullData)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import UI.Inlines.Networking as Inlines exposing (user, addr, file)
import UI.Entries.Toogable exposing (toogableEntry)
import UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Logs.Models as Logs exposing (Format(..))
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Menu.View
    exposing
        ( menuView
        , menuNormalEntry
        , menuEditingEntry
        , menuEncryptedEntry
        , menuHiddenEntry
        , menuFilter
        )
import Apps.LogViewer.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    let
        filterHeaderLayout =
            verticalList
                [ filterHeader
                    [ ( class [ BtnUser ], DummyNoOp, False )
                    , ( class [ BtnEdit ], DummyNoOp, False )
                    , ( class [ BtnHide ], DummyNoOp, False )
                    ]
                    []
                    model.filterText
                    "Search..."
                    UpdateTextFilter
                ]

        mainEntries =
            verticalList
                (data
                    |> Game.getActiveServer
                    |> Servers.getLogs
                    |> applyFilter model
                    |> renderEntries model
                )
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            [ mainEntries
            , menuView model
            ]
            Nothing



-- internals


encrypted : String
encrypted =
    "⠽⠕⠥ ⠚⠥⠎⠞ ⠇⠕⠎⠞ ⠠⠠⠞⠓⠑ ⠠⠠⠛⠁⠍⠑"


renderEntries : Model -> Logs.Model -> List (Html Msg)
renderEntries model logs =
    getLogsfromDate logs
        |> List.map (uncurry <| renderEntry model)


renderEntry : Model -> Logs.ID -> Logs.Log -> Html Msg
renderEntry model id log =
    let
        expandedState =
            isEntryExpanded id model

        editingState =
            isEntryEditing id model

        etop =
            [ div [] [ log.timestamp |> timestampToFullData |> text ]
            , spacer
            , renderTopActions log
            ]

        data =
            [ div [ class [ ETop ] ] etop
            , renderData id log model
            , renderBottom id log model
            ]
    in
        toogableEntry
            (not editingState)
            (menuInclude id log model)
            (ToogleExpand id)
            expandedState
            data


isEntryExpanded : Logs.ID -> Model -> Bool
isEntryExpanded id model =
    List.member id model.expanded


isEntryEditing : Logs.ID -> Model -> Bool
isEntryEditing id model =
    Dict.member id model.editing


renderFlag : Classes -> List (Html Msg)
renderFlag flag =
    [ text " "
    , span [ class [ flag ] ] []
    ]


renderFlags : List Classes -> List (Html Msg)
renderFlags =
    List.map renderFlag
        >> List.concat
        >> List.tail
        >> Maybe.withDefault []


renderContent : Logs.Log -> Html Msg
renderContent log =
    let
        rendered =
            case Logs.getContent log of
                Logs.NormalContent data ->
                    render data

                Logs.Encrypted ->
                    [ span [] [ text encrypted ] ]
    in
        div [] rendered


renderMiniContent : Logs.Log -> Html Msg
renderMiniContent =
    renderContent


renderEditing : Logs.ID -> String -> Html Msg
renderEditing logID src =
    input
        [ class [ BoxifyMe ]
        , value src
        , onInput (UpdateEditing logID)
        ]
        []


renderTopActions : Logs.Log -> Html Msg
renderTopActions log =
    -- TODO: Catch the flags for real
    div [] <| renderFlags [ BtnUser, BtnEdit, BtnCrypt ]


btnsEditing : Logs.ID -> List ( Attribute Msg, Msg )
btnsEditing logID =
    [ ( class [ BtnApply, BottomButton ], ApplyEditing logID )
    , ( class [ BtnCancel, BottomButton ], LeaveEditing logID )
    ]


btnsNormal : Logs.ID -> List ( Attribute Msg, Msg )
btnsNormal logID =
    [ ( class [ BtnCrypt, BottomButton ], StartCrypting logID )
    , ( class [ BtnHide, BottomButton ], StartHiding logID )
    , ( class [ BtnEdit, BottomButton ], EnterEditing logID )
    , ( class [ BtnDelete, BottomButton ], StartDeleting logID )
    ]


btnsCryptographed : Logs.ID -> List ( Attribute Msg, Msg )
btnsCryptographed logID =
    [ ( class [ BtnHide, BottomButton ], StartHiding logID )
    , ( class [ BtnDecrypt, BottomButton ], StartDecrypting logID )
    ]


renderBottomActions : Logs.ID -> Logs.Log -> Model -> Html Msg
renderBottomActions id log model =
    let
        btns =
            if (isEntryEditing id model) then
                btnsEditing id
            else if (isEntryExpanded id model) then
                case log.content of
                    Logs.NormalContent _ ->
                        btnsNormal id

                    Logs.Encrypted ->
                        btnsCryptographed id
            else
                []
    in
        horizontalBtnPanel btns


renderData : Logs.ID -> Logs.Log -> Model -> Html Msg
renderData id log model =
    case (Dict.get id model.editing) of
        Just x ->
            renderEditing id x

        Nothing ->
            if (isEntryExpanded id model) then
                renderContent log
            else
                renderMiniContent log


renderBottom : Logs.ID -> Logs.Log -> Model -> Html Msg
renderBottom id log model =
    let
        data =
            if (isEntryEditing id model) then
                [ renderBottomActions id log model ]
            else if (isEntryExpanded id model) then
                [ renderBottomActions id log model ]
            else
                []
    in
        div
            [ class [ EBottom ] ]
            data


menuInclude : Logs.ID -> Logs.Log -> Model -> List (Attribute Msg)
menuInclude id log model =
    if (isEntryEditing id model) then
        [ menuEditingEntry id ]
    else
        case log.content of
            Logs.NormalContent _ ->
                [ menuNormalEntry id ]

            Logs.Encrypted ->
                [ menuEncryptedEntry id ]


getLogsfromDateHelper :
    Dict Logs.ID Logs.Log
    -> Logs.Date
    -> Logs.ID
    -> List ( Logs.ID, Logs.Log )
    -> List ( Logs.ID, Logs.Log )
getLogsfromDateHelper logs k v a =
    case Dict.get v logs of
        Just log ->
            a ++ [ ( v, log ) ]

        Nothing ->
            a


getLogsfromDate : Logs.Model -> List ( Logs.ID, Logs.Log )
getLogsfromDate logs =
    Dict.foldr (getLogsfromDateHelper logs.logs) [] logs.drawOrder


render : Logs.Data -> List (Html Msg)
render { format, raw } =
    case format of
        Just format ->
            case format of
                LocalLoginFormat data ->
                    [ addr data.from
                    , text " logged in as "
                    , user data.user
                    ]

                RemoteLoginFormat { into } ->
                    [ text "Logged into "
                    , addr into
                    ]

                ConnectionFormat { nip, from, to } ->
                    [ addr nip
                    , text " bounced connection from "
                    , addr from
                    , text " to "
                    , addr to
                    ]

                DownloadByFormat { filename, nip } ->
                    [ text "File "
                    , file filename
                    , text " downloaded by "
                    , file nip
                    ]

                DownloadFromFormat { filename, nip } ->
                    [ text "File "
                    , file filename
                    , text " downloaded from "
                    , addr nip
                    ]

        Nothing ->
            [ text raw ]
