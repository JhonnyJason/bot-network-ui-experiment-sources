############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("backendmodule")
#endregion

############################################################
import * as S from "./statemodule.js"

############################################################
currentBackendObject = null

############################################################
export initialize = ->
    log "initialize"
    return


############################################################
postBackendChange = ->

    S.callOutChange("backend")
    return