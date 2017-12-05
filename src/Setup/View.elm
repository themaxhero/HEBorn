module Setup.View exposing (view)

import Game.Models as Game
import Html exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Setup.Resources exposing (..)
import Setup.Pages.Configs as Configs
import Setup.Pages.Welcome.View as Welcome
import Setup.Pages.CustomWelcome.View as CustomWelcome
import Setup.Pages.Finish.View as Finish
import Setup.Pages.CustomFinish.View as CustomFinish
import Setup.Pages.PickLocation.View as PickLocation
import Setup.Pages.Mainframe.View as Mainframe


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Model -> Model -> Html Msg
view game model =
    if isLoading model then
        loadingView
    else
        case model.page of
            Just page ->
                setupView game page model

            Nothing ->
                loadingView


loadingView : Html Msg
loadingView =
    div []
        [ p [] [ text "Keyboard not found" ]
        , p [] [ text "Press Ctrl+W to quit, keep waiting to continue..." ]
        ]


setupView : Game.Model -> PageModel -> Model -> Html Msg
setupView game page model =
    node setupNode
        []
        [ leftBar page model.pages model
        , viewPage game page
        ]


leftBar : PageModel -> List String -> Model -> Html Msg
leftBar current others model =
    let
        currentPageName =
            pageModelToString current

        mapMarker =
            flip <| stepMarker currentPageName
    in
        node leftBarNode
            []
            [ ul [] <| List.map (mapMarker model) others
            ]


viewPage : Game.Model -> PageModel -> Html Msg
viewPage game page =
    case page of
        WelcomeModel ->
            Welcome.view Configs.welcome

        CustomWelcomeModel ->
            CustomWelcome.view Configs.welcome

        MainframeModel model ->
            Mainframe.view Configs.setMainframeName game model

        PickLocationModel model ->
            PickLocation.view Configs.pickLocation game model

        ChooseThemeModel ->
            -- TODO
            div [] []

        FinishModel ->
            Finish.view Configs.finish

        CustomFinishModel ->
            CustomFinish.view Configs.finish


stepMarker : String -> String -> Model -> Html Msg
stepMarker active other model =
    let
        isSelected =
            if active == other then
                [ Selected ]
            else
                []

        pageColor =
            if hasBadPages model then
                if (isBadPage other model) then
                    [ BadPage ]
                else
                    [ DonePage ]
            else
                []

        attributes =
            [ class (isSelected ++ pageColor)
            , onClick <| GoToPage other
            ]
    in
        li attributes [ text other ]
