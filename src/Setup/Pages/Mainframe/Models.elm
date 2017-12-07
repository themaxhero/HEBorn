module Setup.Pages.Mainframe.Models exposing (..)

import Setup.Settings as Settings exposing (Settings)


type alias Model =
    { hostname : Maybe String
    , okay : Bool
    , error : Maybe Error
    }


type Error
    = InvalidHostname
    | Unknown


settings : Model -> List Settings
settings model =
    case model.hostname of
        Just name ->
            [ Settings.Name name ]

        Nothing ->
            []


initialModel : Model
initialModel =
    { hostname = Nothing
    , okay = False
    , error = Nothing
    }


setMainframeName : String -> Model -> Model
setMainframeName str model =
    if str == "" then
        { model | hostname = Nothing, okay = False }
    else
        { model | hostname = Just str, okay = False }


getHostname : Model -> Maybe String
getHostname =
    .hostname


isOkay : Model -> Bool
isOkay =
    .okay


setOkay : Model -> Model
setOkay model =
    { model | okay = True, error = Nothing }


hasErrorMsg : Model -> Bool
hasErrorMsg model =
    (model.error /= Nothing)


setError : Maybe String -> Model -> Model
setError error model =
    case error of
        Just "hostname_invalid" ->
            { model | error = Just InvalidHostname }

        _ ->
            { model | error = Just Unknown }


okayCondition : Model -> Bool
okayCondition model =
    (isOkay model) && not (hasErrorMsg model)


errorCondition : Model -> Bool
errorCondition model =
    (hasErrorMsg model) && not (isOkay model)


inputColorCondition : Model -> Maybe Bool
inputColorCondition model =
    if okayCondition model then
        Just True
    else if errorCondition model then
        Just False
    else
        Nothing
