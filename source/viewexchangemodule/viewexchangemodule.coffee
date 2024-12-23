############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("viewexchangemodule")
#endregion

############################################################
import * as data from "./exchangedata.js"
import * as triggers from "./navtriggers.js"

############################################################
#region DOM Cache
exchangeIconDisplay = document.getElementById("exchange-icon-display") 

#endregion


############################################################
currentExchange = null

############################################################
export initialize = ->
    log "initialize"
    addControllerButton.addEventListener("click", addControllerButtonClicked)
    return

############################################################
addControllerButtonClicked = ->
    log "addControllerButtonClicked"
    triggers.addController()
    return

############################################################
updateOverviewFrame = ->
    log "updateOverviewFrame"

    iconEl = exchangeIconDisplay.querySelector("use")
    if currentExchange? 
        iconEl.setAttribute("href", currentExchange.iconHref)
        exchangeNameDisplay.textContent = currentExchange.name
        exchangeEvaluationNumber.textContent = currentExchange.currentEvaluation
        exchangeEvaluationUnit.textContent = "€"
    else 
        iconEl.setAttribute("href", "")
        exchangeNameDisplay.textContent = "" 
        exchangeEvaluationNumber.textContent = "-"
        exchangeEvaluationUnit.textContent = "€"

    return

############################################################
export setExchangeOverviewContext = (ctx) ->
    log "setExchangeOverviewContext"
    olog ctx
    throw new Error("Invalid Context for Exchange Overview") if (!ctx? or !ctx.exchangeIndex?)

    currentExchange = await data.getExchange(ctx.exchangeIndex)
    olog currentExchange

    updateOverviewFrame()
    return
