module Setup.Settings
    exposing
        ( Settings(..)
        , SettingTopic(..)
        , groupSettings
        , encodeSettings
        , decodeErrors
        , settingToString
        )

import Dict exposing (Dict)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Utils.Ports.Map exposing (Coordinates)


type Settings
    = Location Coordinates
    | Name String


type SettingTopic
    = AccountTopic
    | ServerTopic


groupSettings : List Settings -> List ( SettingTopic, List Settings )
groupSettings settings =
    let
        reducer setting dict =
            let
                target =
                    getTarget setting

                settings =
                    dict
                        |> Dict.get (toString target)
                        |> Maybe.withDefault []
                        |> (::) setting

                dict_ =
                    Dict.insert (toString target) settings dict
            in
                dict_

        filterer k v =
            case targetFromString k of
                Just target ->
                    Just ( target, v )

                Nothing ->
                    Nothing
    in
        settings
            |> List.foldl reducer Dict.empty
            |> Dict.toList
            |> List.filterMap (uncurry filterer)


encodeSettings : Settings -> ( String, Value )
encodeSettings setting =
    let
        key =
            settingToString setting

        value =
            case setting of
                Location coord ->
                    encodeLocation coord

                Name name ->
                    encodeHostname name
    in
        ( key, value )



-- Receive a List of settings and check if the settings are valid


decodeErrors : List Settings -> Decoder (Dict String String)
decodeErrors =
    let
        filterer errors setting acu =
            let
                key =
                    settingToString setting
            in
                case Dict.get key errors of
                    Just err ->
                        Dict.insert key err acu

                    Nothing ->
                        acu

        mapper checking errors =
            List.foldl (filterer errors) Dict.empty checking

        decoder checking =
            Decode.map (mapper checking) <| Decode.dict Decode.string
    in
        decoder



-- internals


settingToString : Settings -> String
settingToString setting =
    case setting of
        Location _ ->
            "location"

        Name _ ->
            "hostname"


encodeLocation : Coordinates -> Value
encodeLocation { lat, lng } =
    Encode.object
        [ ( "lat", Encode.float lat )
        , ( "lng", Encode.float lng )
        ]


encodeHostname : String -> Value
encodeHostname name =
    Encode.object
        [ ( "hostname", Encode.string name ) ]


getTarget : Settings -> SettingTopic
getTarget settings =
    case settings of
        Location _ ->
            ServerTopic

        Name _ ->
            ServerTopic


targetFromString : String -> Maybe SettingTopic
targetFromString str =
    case str of
        "AccountTopic" ->
            Just AccountTopic

        "ServerTopic" ->
            Just ServerTopic

        _ ->
            Nothing
