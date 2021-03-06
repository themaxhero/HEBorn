module OS.Toasts.Messages exposing (Msg(..))

import Game.Notifications.Source as Notifications
import Game.Notifications.Models as Notifications


type Msg
    = Remove Int
    | Trash Int
    | Fade Int
    | HandleInsert (Maybe Notifications.Source) Notifications.Content
