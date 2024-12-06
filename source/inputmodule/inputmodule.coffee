############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("inputmodule")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as qrReader from "./qrreadermodule.js"
import * as keygeneration from "./keygeneration.js"

############################################################
export initialize = ->
    log "initialize"
    qrReader.allowNonHex(true)

    clickCatcher = phraseinputFrame.getElementsByClassName("click-catcher")[0]
    if clickCatcher? then clickCatcher.addEventListener("click", clickCatcherClicked)
    
    acceptPhraseButton.addEventListener("click", acceptPhraseButtonClicked)
    cancelPhraseButton.addEventListener("click", cancelPhraseButtonClicked)
    
    phraseinput.addEventListener("keyup", phraseinputKeyUpped)
    phraseinput.addEventListener("keydown", phraseinputKeyDowned)
    return


############################################################
turnDown = ->
    log "turnDown"
    phraseinputFrame.classList.remove("active")
    phraseinput.value = ""
    acceptPhraseButton.classList.add("disabled")
    return

############################################################
clickCatcherClicked = ->
    log "clickCatcherClicked"
    nav.toMod("none")
    return

phraseinputKeyDowned = (evnt) ->
    log "phraseinputKeyDowned"
    return unless evnt.key == "Enter" or evnt.keyCode == 13
    return if phraseinput.value.length == 0
    acceptPhraseButtonClicked()
    return

phraseinputKeyUpped = ->
    log "phraseinputKeyUpped"
    if phraseinput.value.length == 0 then acceptPhraseButton.classList.add("disabled")
    else acceptPhraseButton.classList.remove("disabled")
    return

acceptPhraseButtonClicked = ->
    log "acceptPhraseButtonClicked"
    data = phraseinput.value
    keygeneration.usePhraseData(data)
    nav.toMod("none")
    return

cancelPhraseButtonClicked = ->
    log "cancelPhraseButtonClicked"
    nav.toMod("none")
    return


############################################################
export reset = ->
    log "reset"
    qrReader.stop()
    turnDown()
    return

export retrievePhrase = ->
    log "retrievePhrase"
    phraseinputFrame.classList.add("active")
    phraseinput.focus()
    return

export retrieveQrCode = ->
    log "retrieveQrCode"
    data = await qrReader.read()
    nav.toMod("none")
    if data then keygeneration.useQrData(data)
    return