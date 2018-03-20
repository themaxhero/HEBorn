module Game.Account.Database.Requests.VirusInstall exposing (installRequest)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..))
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Models exposing (..)
import Game.Account.Database.Shared exposing (InstallError(..))
import Game.Meta.Types.Network as Network


type alias Data =
    Result InstallError ()


installRequest :
    ID
    -> String
    -> FlagsSource a
    -> Cmd Data
installRequest fileId requestId flagsSrc =
    flagsSrc
        |> Requests.request (Topics.virusInstall id)
            (encoder fileId requestId)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


encoder : ID -> String -> Value
encoder hackedServers bounce requestId =
    let
        valueList =
            List.map (encodeNIP hackedServers) bounce.path
    in
        Encode.object
            [ ( "file_id", Encode.string fileId )
            , ( "request_id", Encode.string requestId )
            ]


errorToString : CreateError -> String
errorToString error =
    case error of
        InstallBadRequest ->
            "Bad Request"

        InstallAlreadyInstalled ->
            "Virus already installed"

        InstallSelf ->
            "You can't install a virus on your own Server"

        InstallFileIsNotInstallable ->
            "This file is not installable"


errorMessage : Decoder CreateError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed InstallBadRequest

                "file_not_installabe" ->
                    succeed InstallFileIsNotInstallable

                "virus_active" ->
                    succeed InstallAlreadyInstalled

                "virus_self_install" ->
                    succeed InstallSelf

                value ->
                    fail <| commonError "virus install error message" value


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "File.Install" code flagsSrc
                |> Result.mapError (always InstallUnknown)
                |> Result.andThen Err
