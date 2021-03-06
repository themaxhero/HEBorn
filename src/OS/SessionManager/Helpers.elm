module OS.SessionManager.Helpers exposing (toSessionID)

import Native.Panic
import Core.Error as Error
import Game.Data exposing (Data)
import Game.Models as Game
import Game.Meta.Types.Context exposing (..)
import Game.Account.Models as Account
import Game.Models as Game
import Game.Servers.Models as Servers
import OS.SessionManager.Types exposing (..)


toSessionID : Data -> ID
toSessionID ({ game } as data) =
    let
        activeContext =
            game
                |> Game.getAccount
                |> Account.getContext

        activeServer =
            Game.Data.getActiveServer data

        servers =
            Game.getServers game
    in
        case activeContext of
            Gateway ->
                data
                    |> Game.Data.getActiveCId
                    |> Servers.toSessionId

            Endpoint ->
                let
                    endpointSessionId =
                        activeServer
                            |> Servers.getEndpointCId
                            |> Maybe.map Servers.toSessionId
                in
                    case endpointSessionId of
                        Just endpointSessionId ->
                            endpointSessionId

                        Nothing ->
                            "U = {x}, ∄ x ⊂ U"
                                |> Error.neeiae
                                |> uncurry Native.Panic.crash
