############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("tutorialmodule")
#endregion

############################################################
import * as triggers from "./navtriggers.js"

############################################################
export initialize = ->
    log "initialize"
    tutorialConfigureKeyButton.addEventListener("click", configureKeyClicked)
    return

#############################################################
configureKeyClicked = ->
    log "configureKeyClicked" 
    triggers.settingsAccount()
    return
