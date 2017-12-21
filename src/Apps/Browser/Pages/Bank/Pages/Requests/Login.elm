module Apps.Browser.Pages.Bank.Requests.Login
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Decoders.Processes
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Network as Network


type Response
    = Valid
    | Invalid


request :
    AtmId
    -> AccountNumber
    -> String
    -> ConfigSource a
    -> Cmd msg
request bank accountNum password data =
    let
        payload =
            Encode.object
                [ ( "bank", Encode.string bank )
                , ( "account", Encode.int account )
                , ( "password", Encode.string password )
                ]

        accountId =
            data
                |> Game.getAccount
                |> Account.getId
    in
        Requests.request (Topics.bankLogin accountId)
            (BankLoginRequest >> Request)
            payload
            data


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            Just Valid

        _ ->
            Just Invalid
