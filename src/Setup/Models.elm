module Setup.Models exposing (..)

import Dict as Dict
import Set as Set exposing (Set)
import Game.Models as Game
import Json.Encode as Encode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Error as Error
import Utils.Core exposing (repeat)
import Utils.List exposing (findIndex)
import Setup.Types exposing (..)
import Setup.Messages exposing (Msg)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.PickLocation.Models as PickLocation
import Setup.Pages.Mainframe.Models as Mainframe


type alias Model =
    { page : CurrentPage
    , pages : List String
    , badPages : Set String
    , remaining : RemainingPages
    , done : PagesDone
    , isLoading : Bool
    , secondPhase : Bool
    , topicsDone : TopicsDone
    , goodPages : Set String
    }


type PageModel
    = WelcomeModel
    | CustomWelcomeModel
    | MainframeModel Mainframe.Model
    | PickLocationModel PickLocation.Model
    | ChooseThemeModel
    | FinishModel
    | CustomFinishModel


type PageError
    = MainframeError Mainframe.Error
    | PickLocationError PickLocation.Error
    | UnknownError


type alias CurrentPage =
    ( Maybe PageModel, Maybe (List Settings) )


type alias PagesDone =
    List ( PageModel, List Settings )


type alias RemainingPages =
    List ( PageModel, List Settings )


type alias TopicsDone =
    { server : Bool
    }


mapId : String
mapId =
    "map-setup"


geoInstance : String
geoInstance =
    "setup"


pageOrder : Pages
pageOrder =
    [ Welcome
    , Mainframe
    , Finish
    ]


remainingPages : Pages -> Pages
remainingPages pages =
    let
        newPages =
            List.filter ((flip List.member pages) >> not) pageOrder
    in
        case List.head newPages of
            Just Welcome ->
                newPages

            Just _ ->
                -- insert local greetings/farewells
                newPages
                    |> List.reverse
                    |> (::) CustomFinish
                    |> List.reverse
                    |> (::) CustomWelcome

            Nothing ->
                []


initializePages : Pages -> List PageModel
initializePages =
    let
        mapper page =
            case page of
                Welcome ->
                    WelcomeModel

                CustomWelcome ->
                    CustomWelcomeModel

                Mainframe ->
                    MainframeModel <| Mainframe.initialModel

                PickLocation ->
                    PickLocationModel <| PickLocation.initialModel

                ChooseTheme ->
                    ChooseThemeModel

                Finish ->
                    FinishModel

                CustomFinish ->
                    CustomFinishModel
    in
        List.map mapper


initialModel : Game.Model -> ( Model, Cmd Msg, Dispatch )
initialModel game =
    let
        model =
            { page = ( Nothing, Nothing )
            , pages = []
            , badPages = Set.empty
            , goodPages = Set.empty
            , remaining = []
            , done = []
            , isLoading = True
            , secondPhase = False
            , topicsDone = initialTopicsDone
            }
    in
        ( model, Cmd.none, Dispatch.none )


initialTopicsDone : TopicsDone
initialTopicsDone =
    { server = True
    }


doneLoading : Model -> Model
doneLoading model =
    { model | isLoading = False }


doneSetup : Model -> Bool
doneSetup model =
    case model.page of
        ( Just _, _ ) ->
            False

        ( Nothing, _ ) ->
            List.isEmpty model.remaining


isLoading : Model -> Bool
isLoading =
    .isLoading


hasPages : Model -> Bool
hasPages =
    .pages >> List.isEmpty >> not


setPages : Pages -> Model -> Model
setPages pages model =
    let
        mapper item =
            ( item, [] )

        models =
            initializePages pages
                |> List.map mapper

        pages_ =
            List.map pageModelToString <| initializePages pages

        remaining =
            models
                |> List.tail
                |> Maybe.withDefault []

        page =
            models
                |> List.head
                |> Maybe.andThen (doneToCurrent)
                |> Maybe.withDefault ( Just WelcomeModel, Nothing )
    in
        { model
            | pages = pages_
            , page = page
            , remaining = remaining
        }


setBadPages : List String -> Model -> Model
setBadPages pages model =
    { model | badPages = Set.fromList pages }


setPage : PageModel -> Model -> Model
setPage page model =
    { model | page = ( Just page, Nothing ) }


getDone : Model -> PagesDone
getDone =
    .done


setTopicsDone : Settings.SettingTopic -> Bool -> Model -> Model
setTopicsDone setting value ({ topicsDone } as model) =
    case setting of
        Settings.ServerTopic ->
            { model | topicsDone = { topicsDone | server = value } }

        _ ->
            model


nextPage : List Settings -> Model -> Model
nextPage settings model =
    let
        page =
            getPageFromRemaining model.remaining model

        remaining =
            model.remaining
                |> List.tail
                |> Maybe.withDefault []

        done =
            case model.page of
                ( Just page, _ ) ->
                    ( page, settings ) :: model.done

                ( Nothing, _ ) ->
                    model.done

        model_ =
            { model
                | page = page
                , remaining = remaining
                , done = done
            }
    in
        model_


previousPage : Model -> Model
previousPage model =
    let
        pagesDone =
            getDone model

        page =
            getPageFromDone model.done model

        done =
            pagesDone
                |> List.tail
                |> Maybe.withDefault []

        remaining =
            case model.page of
                ( Just page, Just settings ) ->
                    ( page, settings ) :: model.remaining

                ( Just page, Nothing ) ->
                    ( page, [] ) :: model.remaining

                ( Nothing, _ ) ->
                    model.remaining

        model_ =
            { model
                | page = page
                , remaining = remaining
                , done = done
            }
    in
        model_


undoPages : Model -> Model
undoPages model =
    let
        pages =
            getDone model
                |> List.reverse

        remaining =
            pages
                |> List.head
                |> Maybe.andThen (flip (::) model.remaining >> Just)
                |> Maybe.withDefault model.remaining

        page =
            pages
                |> List.head
                |> Maybe.andThen (doneToCurrent)
                |> Maybe.withDefault ( Just WelcomeModel, Just [] )

        model_ =
            { model
                | done = []
                , page = page
                , remaining = remaining
            }
    in
        model_


pageModelToString : PageModel -> String
pageModelToString page =
    case page of
        WelcomeModel ->
            "WELCOME"

        CustomWelcomeModel ->
            "WELCOME AGAIN"

        MainframeModel _ ->
            "MAINFRAME"

        PickLocationModel _ ->
            "LOCATION PICKER"

        ChooseThemeModel ->
            "CHOOSE THEME"

        FinishModel ->
            "FINISH"

        CustomFinishModel ->
            "FINISH"


getPageFromRemaining : RemainingPages -> Model -> CurrentPage
getPageFromRemaining remaining model =
    let
        head =
            List.head remaining

        badPage page =
            (pageModelToString >> isBadPage) page model

        newPage page settings =
            ( Just page, Just settings )

        newRemaining =
            Maybe.withDefault [] <| List.tail remaining
    in
        case head of
            Just ( page, settings ) ->
                if model.secondPhase then
                    if (badPage page) then
                        newPage page settings
                    else
                        getPageFromRemaining newRemaining model
                else
                    newPage page settings

            Nothing ->
                ( Nothing, Nothing )


getPageFromDone : PagesDone -> Model -> CurrentPage
getPageFromDone done model =
    let
        head =
            List.head done

        badPage page =
            (pageModelToString >> isBadPage) page model

        newPage page settings =
            ( Just page, Just settings )

        newDone =
            Maybe.withDefault [] <| List.tail done
    in
        case head of
            Just ( page, settings ) ->
                if model.secondPhase then
                    if (badPage page) then
                        newPage page settings
                    else
                        getPageFromRemaining newDone model
                else
                    newPage page settings

            Nothing ->
                ( Nothing, Nothing )


encodeDone : List PageModel -> List Value
encodeDone =
    let
        encodePages page list =
            case encodePageModel page of
                Ok page ->
                    page :: list

                Err msg ->
                    list
    in
        List.foldl encodePages []


encodePageModel : PageModel -> Result String Value
encodePageModel page =
    case page of
        WelcomeModel ->
            Ok <| Encode.string "welcome"

        MainframeModel _ ->
            Ok <| Encode.string "server"

        PickLocationModel _ ->
            Ok <| Encode.string "location_picker"

        ChooseThemeModel ->
            Ok <| Encode.string "theme_selector"

        FinishModel ->
            Ok <| Encode.string "finish"

        _ ->
            Err
                ("Can't convert page `"
                    ++ (pageModelToString page)
                    ++ "' to json, this is a local page."
                )


noTopicsRemaining : Model -> Bool
noTopicsRemaining { topicsDone } =
    topicsDone.server


hasBadPages : Model -> Bool
hasBadPages model =
    not <| Set.isEmpty model.badPages


isBadPage : String -> Model -> Bool
isBadPage page model =
    Set.member page model.badPages


isGoodPage : String -> Model -> Bool
isGoodPage page model =
    Set.member page model.goodPages


insertGoodPage : Model -> Model
insertGoodPage model =
    let
        operation =
            pageModelToString
                >> (flip Set.insert) model.goodPages

        list =
            case model.page of
                ( Just page, _ ) ->
                    operation page

                ( Nothing, _ ) ->
                    model.goodPages

        model_ =
            { model | goodPages = list }
    in
        model_


setupOkay : Model -> Bool
setupOkay model =
    (not <| hasBadPages model) && (not <| Set.isEmpty model.goodPages)


doneToCurrent : ( PageModel, List Settings ) -> Maybe CurrentPage
doneToCurrent ( item, list ) =
    Just ( Just item, Just list )


goToPage : String -> Model -> Model
goToPage newPage model =
    let
        pageName =
            case model.page of
                ( Just page, _ ) ->
                    pageModelToString page

                ( Nothing, _ ) ->
                    ""

        currentIndex =
            case findIndex ((==) pageName) model.pages of
                Just index ->
                    index

                Nothing ->
                    "Current page not found"
                        |> Error.impossible
                        |> uncurry Native.Panic.crash

        nextPageIndex =
            case findIndex ((==) newPage) model.pages of
                Just index ->
                    index

                Nothing ->
                    "Next page not found"
                        |> Error.impossible
                        |> uncurry Native.Panic.crash

        nextPage_ =
            (nextPageIndex - currentIndex)

        settings =
            case model.page of
                ( Just page, Just settings ) ->
                    settings

                ( Just page, Nothing ) ->
                    []

                ( Nothing, _ ) ->
                    []
    in
        if nextPage_ > 0 then
            repeat nextPage_ (nextPage settings) model
        else if nextPage_ < 0 then
            repeat (abs nextPage_) previousPage model
        else
            model
