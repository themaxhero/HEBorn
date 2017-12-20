module Apps.Browser.Pages.Bank.Requests.Login
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Apps.Browser.Pages.Bank.Messages exposing (..)


type Response
    = Okay String String
    | Error


request : String -> String -> ConfigSource a -> Cmd Msg
request accountNumber password =
    Requests.request Topics.login
        (LoginRequest >> Request)
        (encoder accountNumber password)


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Requests.report

        NotFoundCode ->
            Just Error

        _ ->
            Nothing


encoder : String -> String -> Value
encoder accountNumber password =
    Encode.object
        [ ( "account", Encode.string accountNumber )
        , ( "password", Encode.string password )
        ]


decoder : Decoder Response
decoder =
    decode Okay
        |> required "token" Decode.string
        |> required "account" Decode.string
