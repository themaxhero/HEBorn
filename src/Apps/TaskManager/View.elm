module Apps.TaskManager.View exposing (view)

import Time exposing (Time)
import Html exposing (..)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.Widgets.LineGraph exposing (lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Resources exposing (Classes(..), prefix)
import Apps.TaskManager.Menu.View exposing (..)


view : Game.Data -> Model -> Html Msg
view data model =
    let
        tasks =
            data
                |> Game.getActiveServer
                |> Servers.getProcesses
                |> Processes.toList
    in
        div [ class [ MainLayout ] ]
            [ viewTasksTable data tasks data.game.meta.lastTick
            , viewTotalResources model
            , menuView model
            ]



-- PRIVATE


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix



-- private


maybe : Maybe (Html msg) -> Html msg
maybe =
    Maybe.withDefault <| text ""


viewTaskRowUsage : Processes.ResourcesUsage -> Html Msg
viewTaskRowUsage usage =
    let
        un =
            Processes.getUnitUsage >> toFloat
    in
        div []
            [ div [] [ text (frequencyToString <| un usage.cpu) ]
            , div [] [ text (bibytesToString <| un usage.mem) ]
            , div [] [ text (bitsPerSecondToString <| un usage.down) ]
            , div [] [ text (bitsPerSecondToString <| un usage.up) ]
            ]


etaBar : Time -> Float -> Html Msg
etaBar secondsLeft progress =
    let
        formattedTime =
            secondsToTimeNotation secondsLeft
    in
        progressBar progress formattedTime 16


viewState : Time -> Processes.Process -> Html Msg
viewState now proc =
    case Processes.getState proc of
        Processes.Starting ->
            text "Starting..."

        Processes.Running ->
            let
                progress =
                    Processes.getProgressPercentage proc

                timeLeft =
                    proc
                        |> Processes.getCompletionDate
                        |> Maybe.map (flip (-) now)
                        |> Maybe.withDefault 0
            in
                progress
                    |> Maybe.map (etaBar timeLeft)
                    |> maybe

        Processes.Paused ->
            text "Paused"

        Processes.Concluded ->
            text "Completed"

        Processes.Succeeded ->
            text "Completed (success)"

        Processes.Failed _ ->
            -- TODO: match reason
            text "Completed (failure)"


processMenu : ( Processes.ID, Processes.Process ) -> Attribute Msg
processMenu ( id, process ) =
    let
        menu =
            case Processes.getAccess process of
                Processes.Full _ ->
                    case Processes.getState process of
                        Processes.Running ->
                            menuForRunning

                        Processes.Paused ->
                            menuForPaused

                        _ ->
                            menuForComplete

                Processes.Partial _ ->
                    menuForPartial
    in
        menu id


viewTaskRow :
    Game.Data
    -> Time
    -> ( Processes.ID, Processes.Process )
    -> Html Msg
viewTaskRow data now (( _, process ) as entry) =
    let
        usageView =
            process
                |> Processes.getUsage
                |> Maybe.map (viewTaskRowUsage)
                |> maybe
    in
        div [ class [ EntryDivision ], (processMenu entry) ]
            [ div []
                [ text <| Processes.getName process
                , br [] []
                , text "Target: "
                , text <| Tuple.second <| Processes.getTarget process
                , br [] []
                ]
            , div []
                [ viewState now process ]
            , div []
                [ usageView ]
            ]


viewTasksTable : Game.Data -> Entries -> Time -> Html Msg
viewTasksTable data entries now =
    div [ class [ TaskTable ] ]
        ([ div [ class [ EntryDivision ] ]
            -- TODO: Hide when too small (responsive design)
            [ div [] [ text "Process" ]
            , div [] [ text "ETA" ]
            , div [] [ text "Resources" ]
            ]
         ]
            ++ (List.map (viewTaskRow data now) entries)
        )


viewGraphUsage : String -> String -> List Float -> Html Msg
viewGraphUsage title color history =
    let
        sz =
            toFloat ((List.length history) - 1)

        points =
            (List.indexedMap
                (\i x ->
                    ( (1 - toFloat (i) / sz)
                    , (1 - x)
                    )
                )
                history
            )
    in
        lineGraph points color 50 True ( 3, 1 )


viewTotalResources : Model -> Html Msg
viewTotalResources { historyCPU, historyMem, historyDown, historyUp } =
    div [ class [ BottomGraphsRow ] ]
        [ viewGraphUsage "CPU" "green" historyCPU
        , viewGraphUsage "Memory" "blue" historyMem
        , viewGraphUsage "Downlink" "red" historyDown
        , viewGraphUsage "Uplink" "yellow" historyUp
        ]
