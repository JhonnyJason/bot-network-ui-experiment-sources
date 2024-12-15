############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("viewexchangemodule")
#endregion

############################################################
import * as data from "./exchangedata.js"

############################################################
currentExchange = null

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return

############################################################
updateOverviewFrame = ->
    log "updateOverviewFrame"
    return

############################################################
export setExchangeOverviewContext = (ctx) ->
    log "setExchangeOverviewContext"
    olog ctx
    throw new Error("Invalid Context for Exchange Overview") if (!ctx? or !ctx.exchangeIndex?)

    currentExchange = await data.getExchange(ctx.exchangeIndex)
    updateOverviewFrame()
    return
