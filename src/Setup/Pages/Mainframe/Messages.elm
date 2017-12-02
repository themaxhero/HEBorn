module Setup.Pages.Mainframe.Messages exposing (..)

import Setup.Requests.Check as Check


type Msg
    = Mainframe String
    | Validate
    | Checked Check.Response
