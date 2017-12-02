module Setup.Pages.Mainframe.Models exposing (..)

import Setup.Settings as Settings exposing (Settings)


type alias Model =
    { hostname : Maybe String
    , okay : Bool
    , error : Error
    }


type Error
    = InvalidHostname
    | None


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
    , error = None
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
    { model | okay = True, error = None }


hasErrorMsg : Model -> Bool
hasErrorMsg model =
    (model.error /= None)
