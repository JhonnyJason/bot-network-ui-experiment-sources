############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("addexchangemodule")
#endregion

############################################################
import M from "mustache"

############################################################
import * as triggers from "./navtriggers.js"
import * as data from "./exchangedata.js"
import { afExchanges } from "./afexchanges.js"

############################################################
currentApiKey = ""
currentSecretKey = ""

############################################################
typeToExchangeObj = {}

############################################################
optionTemplate = """
    <option value="{{{type}}}">{{{name}}}</option>
"""

############################################################
export initialize = ->
    log "initialize"
    optionsHTML = ""
    optionsHTML += M.render(optionTemplate, exch) for exch in afExchanges

    exchangeSelect.innerHTML = optionsHTML

    addexchangeUseButton.addEventListener("click", addExchangeUseClicked)
    addexchangeCancelButton.addEventListener("click", addExchangeCancelClicked)

    apikeyInput.addEventListener("change" , addExchangeInputsChanged)
    secretkeyInput.addEventListener("change", addExchangeInputsChanged)
    return

############################################################
addExchangeUseClicked = ->
    log "addExchangeUseClicked"
    type = exchangeSelect.value
    await addExchange(type)
    resetAddExchangeUI()
    triggers.mainView()
    return

addExchangeCancelClicked = ->
    log "addExchangeCancelClicked"
    resetAddExchangeUI()
    triggers.back()
    return

addExchangeInputsChanged = ->
    log "addExchangeInputsChanged"
    currentApiKey = apikeyInput.value
    currentSecretKey = secretkeyInput.value
    
    olog { currentApiKey, currentSecretKey }
    
    if currentApiKey and currentSecretKey then addexchangeUseButton.classList.remove("disabled")
    else addexchangeUseButton.classList.add("disabled")
    return

############################################################
addExchange = (type) ->
    obj = {}
    obj.type = type
    obj.apikey = currentApiKey
    obj.secretkey = currentSecretKey

    try await data.addExchange(obj)
    catch err then msgBox.error(err.message)
    return

############################################################
resetAddExchangeUI = ->
    log "resetAddExchangeUI"
    apikeyInput.value = ""
    secretkeyInput.value = ""
    addexchangeUseButton.classList.add("disabled")
    return

