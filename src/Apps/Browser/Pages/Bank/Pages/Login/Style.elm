module Apps.Browser.Pages.Bank.Pages.Login.Style exposing (css)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, button, form, typeSelector)
import Css.Common exposing (flexContainerHorz, flexContainerVert, internalPadding, internalPaddingSz)
import UI.Colors as Colors
import Apps.Browser.Pages.Bank.Pages.Login.Resources
    exposing
        ( Classes(..)
        , prefix
        )


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        []
