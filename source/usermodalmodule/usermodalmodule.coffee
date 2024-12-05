############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usermodalmodule")
#endregion

############################################################
import * as deleteConfirmation from "./deleteconfirmation.js"

############################################################
export initialize = ->
    log "initialize"
    deleteConfirmation.initialize()
    return