############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("navtriggers")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as S from "./statemodule.js"

############################################################
## Navigation Action Triggers

############################################################
export mainView = ->
    return nav.toBaseAt("global-overview", null, 1)

############################################################
export reset = ->
    return nav.toRoot(true)

############################################################
export back = ->
    return nav.back(1)
    
############################################################
export menu = (menuOn) ->
    if menuOn then return nav.toMod("menu")
    else return nav.toMod("none")
 