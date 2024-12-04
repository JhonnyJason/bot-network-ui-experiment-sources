############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("contentmodule")
#endregion

############################################################
# import { createClient as createRPCClient } from "./rpcclientmodule.js"
# import { createClient as createAuthClient } from "./authclientmodule.js"
# import { createClient as createObserverClient } from "./observerclientmodule.js"
import { RPCAuthMasterClient } from "thingy-rpc-authmaster-client"
import * as state from "./statemodule.js"
import { info, error } from "./messageboxmodule.js"
import * as cryptoUtl from "secret-manager-crypto-utils"
import * as triggers from "./navtriggers.js"


#############################################################
export initialize = ->
    tutorialConfigureKeyButton.addEventListener("click", configureKeyClicked)
    return

#############################################################
configureKeyClicked = ->
    log "configureKeyClicked" 
    triggers.settingsAccount()
    return

############################################################
export setToNoKeyState = ->
    log "setToNoKeyState"
    content.className = "no-key"
    return

export setToGlobalOverviewState = ->
    log "setToGlobalOverviewState"
    content.className = "global-overview"
    return

export setToStrategyOverviewState = (ctx) ->
    log "setToStrategyOverviewState"
    ##TODO 
    return
