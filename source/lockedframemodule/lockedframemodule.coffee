############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("lockedframemodule")
#endregion

############################################################
import * as triggers from "./navtriggers.js"
import * as account from "./accountmodule.js"

############################################################
export initialize = ->
    log "initialize"
    lockedUnlockButton.addEventListener("click", unlockClicked)
    lockedDeleteButton.addEventListener("click", deleteClicked)
    return

############################################################
unlockClicked = ->  
    log "unlockClicked"
    keyInfo = account.getKeyInfo()
    switch keyInfo.protection
        when "phrase" then return triggers.unlockWithPhrase()
        when "qr" then return triggers.unlockWithQR()
        else throw new Error("Unlock on invalid protection: #{keyInfo.protection}")
    return

deleteClicked = ->
    log "deleteClicked"
    triggers.deleteKey()
    return

