module Apps.Config exposing (Config)

import Game.Meta.Context exposing (Context(..))


type alias WindowID =
    String


type alias ServerID =
    String


type alias SessionID =
    String


type alias Config =
    { sessionId : SessionID
    , windowId : WindowID
    , context : Context
    }
