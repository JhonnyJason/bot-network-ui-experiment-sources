############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("contentmodule")
#endregion

############################################################
export setToTutorialState = ->
    log "setToTutorialState"
    content.className = "tutorial"
    return

export setToLockedKeyState = ->
    log "setToLockedKeyState"
    content.className = "locked"
    return

export setToGlobalOverviewState = ->
    log "setToGlobalOverviewState"
    content.className = "global-view"
    return

export setToAddExchangeState = ->
    log "setToAddExchangeState"
    content.className = "add-exchange"
    return

export setToExchangeOverviewState = (ctx) ->
    log "setToExchangeOverviewState"
    content.className = "exchange-overview"
    return

export setToControllerOverviewState = (ctx) ->
    log "setToControllerOverviewState"
    content.className = "controller-overview"
    return
