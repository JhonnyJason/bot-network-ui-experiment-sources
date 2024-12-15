############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("globalviewmodule")
#endregion

############################################################
import M from "mustache"

############################################################
import * as S from "./statemodule.js"
import * as triggers from "./navtriggers.js"
import * as account from "./accountmodule.js"
import * as data from "./exchangedata.js"

############################################################
#region DOM Cache
templateContainer = document.getElementById("exchange-display-entry-template-container") 
totalEvaluationNumber = document.getElementById("total-evaluation-number")
totalEvaluationUnit = document.getElementById("total-evaluation-unit")

#endregion

############################################################
entryTemplate = templateContainer.innerHTML

############################################################
allExchanges = null
totalEvaluation = 0
evaluationUnit = "€"

############################################################
export initialize = ->
    log "initialize"
    addExchangeButton.addEventListener("click", addExchangeButtonClicked)

    S.addOnChangeListener("exchangeData", updateData)
    updateData()
    return

############################################################
addExchangeButtonClicked = ->
    log "addExchangeButtonClicked"
    triggers.addExchange()
    return

#entry -> exchange-overview-button
exchangeOverviewClicked = (evnt) ->
    log "exchangeOverviewClicked"
    entry = this.parentElement
    index = entry.getAttribute("index")
    triggers.controlExchange(index)
    return

############################################################
updateData = ->
    log "updateData"
    await getCurrentData()
    updateDisplay()
    attachExchangeEventListeners()
    return

############################################################
updateDisplay  = ->
    log "updateDisplay"
    updateTotalEvaluationDisplay()
    updateAllExchangesDisplay()
    return

############################################################
updateTotalEvaluationDisplay = ->
    log "updateTotalEvaluationDisplay"
    totalEvaluation = 0    
    for exch in allExchanges when typeof exch.currentEvaluation == "number"
        totalEvaluation += exch.currentEvaluation  

    totalEvaluationNumber.textContent = totalEvaluation
    totalEvaluationUnit.textContent = evaluationUnit
    return

updateAllExchangesDisplay = ->
    log "updateAllExchangesDisplay"
    html = ""

    for exch, i in allExchanges
        cObj = {}
        
        cObj.i = i
        cObj.evaluationUnit = evaluationUnit

        cObj.iconHref = exch.iconHref
        cObj.name = exch.name
        cObj.currentEvaluation = exch.currentEvaluation

        html += M.render(entryTemplate, cObj)

    allExchangesDisplay.innerHTML = html
    return

############################################################
attachExchangeEventListeners = ->
    log "attachExchangeEventListeners"
    buttons = globalviewFrame.getElementsByClassName("exchange-overview-button")
    b.addEventListener("click", exchangeOverviewClicked) for b in buttons
    return

############################################################
getCurrentData = -> allExchanges = await data.getExchangeData()
