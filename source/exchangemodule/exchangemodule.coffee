############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("exchangemodule")
#endregion

############################################################
import * as triggers from "./navtriggers.js"
import * as data from "./datamodule.js"

############################################################
currentApiKey = ""
currentSecretKey = ""

############################################################
export initialize = ->
    log "initialize"
    addexchangeUseButton.addEventListener("click", addExchangeUseClicked)
    addexchangeCancelButton.addEventListener("click", addExchangeCancelClicked)

    apikeyInput.addEventListener("change" , addexchangeInputsChanged)
    secretkeyInput.addEventListener("change", addexchangeInputsChanged)
    return


############################################################
createKrakenExchange = ->
    log "createKrakenExchange"
    addexchangeObj = {
        type: "kraken"
        apikey: currentApiKey
        secretkey: currentSecretKey
    }
    data.addExchange(addexchangeObj)
    return


createBinanceExchange = ->
    log "createBinanceExchange"
    addexchangeObj = {
        type: "binance"
        apikey: currentApiKey
        secretkey: currentSecretKey
    }
    data.addExchange(addexchangeObj)
    return

############################################################
resetAddExchangeUI = ->
    log "resetAddExchangeUI"
    apikeyInput.value = ""
    secretkeyInput.value = ""
    addexchangeUseButton.classList.add("disabled")
    return

############################################################
addExchangeUseClicked = -> 
    log "addExchangeUseClicked"
    option = exchangeSelect.value
    switch option
        when "kraken" then createKrakenExchange()
        when "binance" then createBinanceExchange()
        else throw new Error("Unexpected option value: #{option}")
    resetAddExchangeUI()
    return


addExchangeCancelClicked = ->
    log "addExchangeCancelClicked"
    resetAddExchangeUI()
    triggers.back()
    return

addexchangeInputsChanged = ->
    log "addexchangeInputsChanged"
    currentApiKey = apikeyInput.value
    currentSecretKey = secretkeyInput.value
    
    olog { currentApiKey, currentSecretKey }
    
    if currentApiKey and currentSecretKey then addexchangeUseButton.classList.remove("disabled")
    else addexchangeUseButton.classList.add("disabled")
    return


