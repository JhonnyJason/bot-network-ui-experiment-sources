############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("unlockmodule")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as qrReader from "./qrreadermodule.js"
import * as account from "./accountmodule.js"
import * as msgBox from "./messageboxmodule.js"

############################################################
export initialize = ->
    log "initialize"
    qrReader.allowNonHex(true)

    clickCatcher = phraseunlockFrame.getElementsByClassName("click-catcher")[0]
    if clickCatcher? then clickCatcher.addEventListener("click", clickCatcherClicked)
    
    unlockButton.addEventListener("click", unlockButtonClicked)
    cancelUnlockButton.addEventListener("click", cancelUnlockButtonClicked)
    
    phraseunlockInput.addEventListener("keyup", inputKeyUpped)
    phraseunlockInput.addEventListener("keydown", inputKeyDowned)
    return

############################################################
#region internalFunctions
turnDown = ->
    log "turnDown"
    phraseunlockFrame.classList.remove("active")
    phraseunlockInput.value = ""
    unlockButton.classList.add("disabled")
    return

############################################################
clickCatcherClicked = ->
    log "clickCatcherClicked"
    nav.toMod("none")
    return

inputKeyDowned = (evnt) ->
    log "phraseinputKeyDowned"
    return unless evnt.key == "Enter" or evnt.keyCode == 13
    return if phraseunlockInput.value.length == 0
    unlockButtonClicked()
    return

inputKeyUpped = ->
    log "inputKeyUpped"
    if phraseunlockInput.value.length == 0 then unlockButton.classList.add("disabled")
    else unlockButton.classList.remove("disabled")
    return

unlockButtonClicked = ->
    log "unlockButtonClicked"
    data = phraseunlockInput.value
    try 
        await account.unlockKey(data)
        nav.toMod("none")
    catch err then msgBox.error(err.message)
    return

cancelUnlockButtonClicked = ->
    log "cancelUnlockButtonClicked"
    nav.toMod("none")
    return

#endregion

############################################################
export reset = ->
    log "reset"
    qrReader.stop()
    turnDown()
    return

############################################################
export qrUnlock = ->
    log "qrUnlock"
    data = await qrReader.read()
    if !data then return
    
    try
        account.unlockKey(data)
        nav.toMod("none")
    catch err then msgBox(err.message)
    return

export phraseUnlock = ->
    log "phraseUnlock"
    phraseunlockFrame.classList.add("active")
    phraseunlockInput.focus()
    return
