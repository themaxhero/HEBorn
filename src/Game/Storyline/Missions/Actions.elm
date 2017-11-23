module Game.Storyline.Missions.Actions exposing (Action(..))

import Game.Meta.Context exposing (Context)
import Apps.Apps exposing (App)


type alias ID =
    String


type Action
    = RunFile ID
    | GoApp App Context
