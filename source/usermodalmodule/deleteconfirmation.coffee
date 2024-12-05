############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("deleteconfirmation")
#endregion

############################################################
import { ModalCore } from "./modalcore.js"

############################################################
#region Internal Variables
core = null

############################################################
promiseConsumed = false

#endregion

############################################################
export initialize =  ->
    log "initialize"
    core = new ModalCore(deleteconfirmation)
    core.connectDefaultElements()

    messageElement = deleteconfirmation.getElementsByClassName("modal-content")[0]
    return

############################################################
export userConfirmation = ->
    log "userConfirmation"
    core.activate() unless core.modalPromise?
    promiseConsumed = true
    return core.modalPromise

############################################################
#region UI State Manipulation

export turnUpModal = (ctx) ->
    log "turnUpModal"
    return if core.modalPromise? # already up
    
    core.activate()
    return

export turnDownModal = (reason) ->
    log "turnDownModal"
    if core.modalPromise? and !promiseConsumed 
        core.modalPromise.catch(()->return)
        # core.modalPromise.catch((err) -> log("unconsumed: #{err}"))

    core.reject(reason)
    promiseConsumed = false
    return

#endregion