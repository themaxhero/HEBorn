module Setup.Pages.PickLocation.Messages exposing (..)

import Json.Encode exposing (Value)


type Msg
    = MapClick Value
    | GeoLocResp Value
    | GeoRevResp Value
    | SetError String
    | ResetLoc
    | Checked (Maybe String)
