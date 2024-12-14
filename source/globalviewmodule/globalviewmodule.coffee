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
import * as data from "./datamodule.js"

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

    S.addOnChangeListener("account", updateData)
    updateData()
    return

############################################################
addExchangeButtonClicked = ->
    log "addExchangeButtonClicked"
    triggers.addExchange()
    return


############################################################
updateData = ->
    log "updateData"
    await loadData()
    updateDisplay()
    attachExchangeEventListeners()
    return

updateDisplay  = ->
    log "updateDisplay"
    totalEvaluationNumber.textContent = totalEvaluation
    totalEvaluationUnit.textContent = evaluationUnit

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

attachExchangeEventListeners = ->
    log "attachExchangeEventListeners"
    return

loadData = ->
    allExchanges = await data.getAllExchangesData()
    
    totalEvaluation = 0
    totalEvaluation += exch.currentEvaluation for exch in allExchanges

    return

############################################################
saveData = ->
    log "saveData"
    await data.saveAllExchangesData(allExchanges)
    return