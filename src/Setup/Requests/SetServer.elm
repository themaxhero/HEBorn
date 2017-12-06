module Setup.Requests.SetServer
    exposing
        ( Response
        , request
        , receive
        )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ResponseType, ConfigSource, Code(..))
import Game.Servers.Shared as Servers
import Setup.Settings exposing (..)
import Setup.Messages exposing (..)
import Setup.Models exposing (..)


type alias Response =
    Dict String String


request : List Settings -> Servers.CId -> ConfigSource a -> Cmd Msg
request settings cid =
    Requests.request (Topics.serverConfigSet cid)
        (SetServerRequest settings >> Request)
        (Encode.object <| List.map encodeSettings settings)


receive : List Settings -> Code -> Value -> Maybe Response
receive settings code value =
    case code of
        OkCode ->
            Just Dict.empty

        _ ->
            case Decode.decodeValue (decodeErrors settings) value of
                Ok list ->
                    Just list

                Err _ ->
                    Nothing
