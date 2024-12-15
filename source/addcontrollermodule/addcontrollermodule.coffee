############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("addcontrollermodule")
#endregion

############################################################
import M from "mustache"

############################################################
import * as triggers from "./navtriggers.js"
import * as data from "./datamodule.js"
import { afControllers } from "./afcontrollers.js"

############################################################
typeToControllerObj = {}

optionTemplate = """
    <option value="{{{type}}}">{{{name}}}</option>  
"""

############################################################
export initialize = ->
    log "initialize"
    optionsHTML = ""
    for ctlr in afControllers
        typeToControllerObj[ctlr.type] = ctlr
        optionsHTML += M.render(optionTemplate, ctlr)

    controllerSelect.innerHTML = optionsHTML

    addcontrollerUseButton.addEventListener("click", addControllerClicked)
    addcontrollerCancelButton.addEventListener("click", cancelClicked)
    return

############################################################
addControllerClicked = ->
    log "addControllerClicked"
    alert("Adding Controller not implemented yet!")
    ## TODO implement
    triggers.back()
    return

cancelClicked = ->
    log "cancelClicked"
    triggers.back()
    return



