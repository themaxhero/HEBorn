module Core.Config exposing (..)

import Time exposing (Time)
import Driver.Websocket.Channels exposing (Channel(ServerChannel, AccountChannel))
import Driver.Websocket.Messages as Ws
import Setup.Config as Setup
import OS.Config as OS
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.Toasts.Messages as Toast
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Game.Config as Game
import Game.Messages as Game
import Game.Account.Models as Account
import Game.Account.Messages as Account
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared exposing (CId)
import Game.Storyline.Models as Story
import Core.Flags exposing (Flags)
import Core.Error as Error exposing (Error)
import Core.Messages exposing (..)


gameConfig : Game.Config Msg
gameConfig =
    { toMsg = GameMsg
    , batchMsg = MultiMsg

    -- game & web
    , onJoinServer =
        \cid payload ->
            payload
                |> Ws.HandleJoin (ServerChannel cid)
                |> WebsocketMsg
    , onError =
        HandleCrash

    -- web
    , onDNS =
        \response { sessionId, windowId, context, tabId } ->
            Browser.HandleFetched response
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg
    , onJoinFailed =
        \{ sessionId, windowId, context, tabId } ->
            Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> Apps.BrowserMsg
                |> SessionManager.AppMsg ( sessionId, windowId ) context
                |> OS.SessionManagerMsg
                |> OSMsg

    --- account
    , onConnected =
        \accountId ->
            Nothing
                |> Ws.HandleJoin (AccountChannel accountId)
                |> WebsocketMsg
    , onDisconnected = HandleShutdown

    -- account.notifications
    , onAccountToast =
        Toast.HandleAccount
            >> OS.ToastsMsg
            >> OSMsg
    , onServerToast =
        \cid ->
            Toast.HandleServers cid
                >> OS.ToastsMsg
                >> OSMsg

    -- account.finances
    , onBALoginSuccess = (\a b -> MultiMsg [])
    , onBALoginFailed = (\a -> MultiMsg [])
    , onBATransferSuccess = (\a -> MultiMsg [])
    , onBATransferFailed = (\a -> MultiMsg [])
    }


setupConfig : String -> CId -> Flags -> Setup.Config Msg
setupConfig accountId mainframe flags =
    { toMsg = SetupMsg
    , accountId = accountId
    , mainframe = mainframe
    , flags = flags
    }


osConfig :
    Game.Model
    -> ( CId, Server )
    -> Context
    -> ( CId, Server )
    -> OS.Config Msg
osConfig game srv ctx gtw =
    { toMsg = OSMsg
    , flags = Game.getFlags game
    , account = Game.getAccount game
    , story = Game.getStory game
    , activeServer = srv
    , activeContext = ctx
    , activeGateway = gtw
    , servers = Gamet.getServers game
    , lastTick = Meta.getLastTick <| Game.getMeta <| game
    , onLogout =
        Account.Logout
            |> Game.AccountMsg
            |> GameMsg
    , onSetGateway =
        Account.OnSetGateway
            |> Game.AccountMsg
            |> GameMsg
    , onSetEndpoint =
        Account.OnSetEndpoint
            |> Game.AccountMsg
            |> GameMsg
    , onSetContext =
        Account.OnSetContext
            |> Game.AccountMsg
            |> GameMsg
    , onSetBounce =
        \bounce ->
            Server.OnSetBounce bounce
                |> Server cid
                |> ServersMsg
                |> GameMsg
    , onSetStoryMode =
        Storyline.OnSetMode
            |> StorylineMsg
            |> GameMsg
    , onReadAllAccountNotifications =
        Account.ReadAllNotifications
            |> Game.AccountMsg
            |> GameMsg
    , onReadAllServerNotifications =
        Server.ReadAllNotifications
            |> Server
            >> Game.ServersMsg
            >> GameMsg
    , onSetActiveNIP =
        \nip ->
            Server.SetActiveNIP nip
                |> Server cid
                |> Game.ServersMsg
                |> GameMsg
    }
