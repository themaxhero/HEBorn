module Apps.Browser.Pages.Bank.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, button, form, typeSelector)
import Css.Common exposing (flexContainerHorz, flexContainerVert, internalPadding, internalPaddingSz)
import UI.Colors as Colors
import Apps.Browser.Pages.Bank.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Bank.Pages.Login.Style as Login
import Apps.Browser.Pages.Bank.Pages.MainPage.Style as MainPage
import Apps.Browser.Pages.Bank.Pages.Transfer.Style as Transfer


cssList : List Stylesheet
cssList =
    [ Login.css
    , MainPage.css
    , Transfer.css
    ]
