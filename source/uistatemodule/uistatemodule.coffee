############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("uistatemodule")
#endregion

############################################################
#region imported UI modules
import * as content from "./contentmodule.js"
import * as settings from "./settingsmodule.js"

## User Modals
############################################################
import * as deleteConfirmation from "./deleteconfirmation.js"

#endregion

############################################################
applyBaseState = {}
applyModifier = {}

############################################################
currentBase = null
currentModifier = null
currentContext = null

############################################################
#region Base State Application Functions

applyBaseState["no-key"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToNoKeyState(ctx)
    # masterKey.focusFloatingSecretInput()
    return


############################################################
# States on App Usage
applyBaseState["global-overview"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToGlobalOverviewState(ctx)
    # servers.display(ctx)
    return

applyBaseState["strategy-overview"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToStrategyOverviewState(ctx)
    # servers.setEditData(ctx)
    return


############################################################
# States on Settings
applyBaseState["settings"] = (ctx) ->
    settings.switchSettingsOn()
    return

applyBaseState["settings-account"] = (ctx) ->
    settings.switchSettingsOn("account")
    return

applyBaseState["settings-backend"] = (ctx) ->
    settings.switchSettingsOn("backend")
    return

#endregion

############################################################
resetAllModifications = ->
    deleteConfirmation.turnDownModal("uiState changed")
    return

############################################################
#region Modifier State Application Functions

applyModifier["none"] = (ctx) ->
    resetAllModifications()
    return

applyModifier["deleteconfirmation"] = (ctx) ->
    resetAllModifications()
    deleteConfirmation.turnUpModal(ctx)
    return


#endregion


############################################################
#region exported general Application Functions
export applyUIState = (base, modifier, ctx) ->
    log "applyUIState"
    currentContext = ctx

    if base? then applyUIStateBase(base)
    if modifier? then applyUIStateModifier(modifier)
    return

############################################################
export applyUIStateBase = (base) ->
    log "applyUIBaseState #{base}"
    applyBaseFunction = applyBaseState[base]

    if typeof applyBaseFunction != "function" then throw new Error("on applyUIStateBase: base '#{base}' apply function did not exist!")

    currentBase = base
    applyBaseFunction(currentContext)
    return

############################################################
export applyUIStateModifier = (modifier) ->
    log "applyUIStateModifier #{modifier}"
    applyModifierFunction = applyModifier[modifier]

    if typeof applyUIStateModifier != "function" then throw new Error("on applyUIStateModifier: modifier '#{modifier}' apply function did not exist!")

    currentModifier = modifier
    applyModifierFunction(currentContext)
    return

############################################################
export getModifier = -> currentModifier
export getBase = -> currentBase
export getContext = -> currentContext

#endregion