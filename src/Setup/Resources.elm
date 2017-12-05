module Setup.Resources exposing (..)


type Class
    = StepWelcome
    | StepPickLocation
    | StepChooseTheme
    | StepFinish
    | Selected
    | DonePage
    | BadPage


prefix : String
prefix =
    "setup"


setupNode : String
setupNode =
    prefix ++ "Wiz"


leftBarNode : String
leftBarNode =
    prefix ++ "Steps"


contentNode : String
contentNode =
    prefix ++ "Main"
