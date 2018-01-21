module Core.Config exposing (..)

import Time exposing (Time)
import Driver.Websocket.Channels exposing (Channel(ServerChannel, AccountChannel))
import Driver.Websocket.Messages as Ws
import Core.Flags exposing (Flags)
import Core.Error as Error exposing (Error)
import Core.Messages exposing (..)
import Landing.Config as Landing
import Setup.Config as Setup
import Game.Config as Game
import Game.Messages as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Account.Messages as Account
import Game.Account.Notifications.Messages as AccNotif
import Game.Meta.Models as Meta
import Game.Meta.Types.Context exposing (..)
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Notifications.Messages as SrvNotif
import Game.Storyline.Messages as Story
import Game.Storyline.Models as Story
import OS.Config as OS
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.Toasts.Messages as Toast
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser


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


landingConfig : Bool -> Flags -> Landing.Config Msg
landingConfig windowLoaded flags =
    { flags = flags
    , toMsg = LandingMsg
    , onLogin = HandleBoot
    , windowLoaded = windowLoaded
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
osConfig game (( cid, _ ) as srv) ctx gtw =
    { toMsg = OSMsg
    , flags = Game.getFlags game
    , account = Game.getAccount game
    , story = Game.getStory game
    , activeServer = srv
    , activeContext = ctx
    , activeGateway = gtw
    , servers = Game.getServers game
    , lastTick = Meta.getLastTick <| Game.getMeta <| game
    , onLogout =
        Account.HandleLogout
            |> Game.AccountMsg
            |> GameMsg
    , onSetGateway =
        Account.HandleSetGateway
            >> Game.AccountMsg
            >> GameMsg
    , onSetEndpoint =
        Account.HandleSetEndpoint
            >> Game.AccountMsg
            >> GameMsg
    , onSetContext =
        Account.HandleSetContext
            >> Game.AccountMsg
            >> GameMsg
    , onSetBounce =
        Servers.HandleSetBounce
            >> Servers.ServerMsg cid
            >> Game.ServersMsg
            >> GameMsg
    , onSetStoryMode =
        Story.HandleSetMode
            >> Game.StoryMsg
            >> GameMsg
    , onReadAllAccountNotifications =
        AccNotif.HandleReadAll
            |> Account.NotificationsMsg
            |> Game.AccountMsg
            |> GameMsg
    , onReadAllServerNotifications =
        SrvNotif.HandleReadAll
            |> Servers.NotificationsMsg
            |> Servers.ServerMsg cid
            |> Game.ServersMsg
            |> GameMsg
    , onSetActiveNIP =
        Servers.HandleSetActiveNIP
            >> Servers.ServerMsg cid
            >> Game.ServersMsg
            >> GameMsg
    }
