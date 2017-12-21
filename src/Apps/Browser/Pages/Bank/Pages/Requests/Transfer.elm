module Apps.Browser.Pages.Bank.Requests.Transfer
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
    = Successful
    | Error


request :
    AtmId
    -> AccountNumber
    -> AtmId
    -> AccountNumber
    -> Int
    -> ConfigSource a
    -> Cmd msg
request fromBank from toBank to value data =
    let
        payload =
            Encode.object
                [ ( "from_bank", Encode.string fromBank )
                , ( "from", Encode.int from )
                , ( "to_bank", Encode.string toBank )
                , ( "to", Encode.int to )
                , ( "value", Encode.int value )
                ]

        accountId =
            data
                |> Game.getAccount
                |> Account.getId
    in
        Requests.request (Topics.bankTransfer accountId)
            (BankTransferRequest >> Request)
            payload
            data


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            Just Successful

        _ ->
            Just Error
