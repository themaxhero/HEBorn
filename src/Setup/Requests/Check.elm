module Setup.Requests.Check exposing (..)

import Native.Panic
import Core.Error as Error
import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , string
        , succeed
        , map
        , fail
        , field
        , decodeValue
        )
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)
import Game.Servers.Shared exposing (CId)
import Utils.Ports.Map exposing (Coordinates)
import Setup.Settings exposing (..)
import Game.Models as Game
import Setup.Pages.Mainframe.Models as Mainframe
import Setup.Pages.Mainframe.Messages as Mainframe


type MsgCheck
    = Invalid (Maybe String)
    | Valid Bool



{- This is a meta/multi request module, use it to build custom requests -}


serverName :
    (MsgCheck -> msg)
    -> String
    -> CId
    -> ConfigSource a
    -> Cmd msg
serverName func name cid =
    name
        |> Name
        |> encodeSettings
        |> encodeKV
        |> Requests.request (Topics.serverConfigCheck cid)
            (uncurry receiveServerName >> func)


serverLocation :
    (Maybe String -> msg)
    -> Coordinates
    -> CId
    -> ConfigSource a
    -> Cmd msg
serverLocation func coords cid =
    coords
        |> Location
        |> encodeSettings
        |> encodeKV
        |> Requests.request (Topics.serverConfigCheck cid)
            (uncurry receiveServerLocation >> func)



-- internals


encodeKV : ( String, Value ) -> Value
encodeKV ( key, value ) =
    Encode.object
        [ ( "key", Encode.string key )
        , ( "value", value )
        ]


receiveServerName : Code -> Value -> MsgCheck
receiveServerName code value =
    let
        msgError =
            case decodeValue decodeError value of
                Ok (Invalid (Just str)) ->
                    Invalid (Just str)

                Err msg ->
                    "Could not decode error message"
                        |> Error.impossible
                        |> Native.Panic.crash

                _ ->
                    "Unknown Error Message"
                        |> Error.impossible
                        |> Native.Panic.crash
    in
        case code of
            OkCode ->
                Valid True

            _ ->
                msgError


receiveServerLocation : Code -> Value -> Maybe String
receiveServerLocation code value =
    case code of
        OkCode ->
            case decodeValue decodeLocation value of
                Ok string ->
                    Just string

                Err msg ->
                    -- TODO: define errors
                    Nothing

        _ ->
            Nothing


decodeLocation : Decoder String
decodeLocation =
    field "address" string


decodeError : Decoder MsgCheck
decodeError =
    let
        decodedField =
            string
                |> field "message"

        decodeError_ field =
            case field of
                "hostname_invalid" ->
                    Invalid <| Just "hostname_invalid"

                _ ->
                    Invalid Nothing
    in
        map decodeError_ decodedField
