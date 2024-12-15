############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("uistatemodule")
#endregion

############################################################
#region imported UI modules
import * as content from "./contentmodule.js"
import * as exchangeView from "./viewexchangemodule.js"
import * as settings from "./settingsmodule.js"
import * as accountSettings from "./accountsettingsmodule.js"
import * as input from "./inputmodule.js"
import * as unlock from "./unlockmodule.js"

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
    content.setToTutorialState(ctx)
    # masterKey.focusFloatingSecretInput()
    return

applyBaseState["locked-key"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToLockedKeyState(ctx)
    # masterKey.focusFloatingSecretInput()
    return


############################################################
# States on App Usage
applyBaseState["global-view"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToGlobalOverviewState(ctx)
    return

applyBaseState["add-exchange"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToAddExchangeState(ctx)
    return

applyBaseState["exchange-overview"] = (ctx) ->
    settings.switchSettingsOff()
    content.setToExchangeOverviewState(ctx)
    exchangeView.setExchangeOverviewContext(ctx)
    return


############################################################
# States on Settings
applyBaseState["settings"] = (ctx) ->
    settings.switchSettingsOn()
    accountSettings.setOff()
    return

applyBaseState["settings-account"] = (ctx) ->
    settings.switchSettingsOn("account")
    accountSettings.setOff()
    return

applyBaseState["settings-backend"] = (ctx) ->
    settings.switchSettingsOn("backend")
    accountSettings.setOff()
    return

applyBaseState["settings-account-keygeneration"] = (ctx) ->
    settings.switchSettingsOn("account")
    accountSettings.setToKeyGeneration()
    return

applyBaseState["settings-account-keyimport"] = (ctx) ->
    settings.switchSettingsOn("account")
    accountSettings.setToKeyImport()
    return

applyBaseState["settings-account-keyexport"] = (ctx) ->
    settings.switchSettingsOn("account")
    accountSettings.setToKeyExport()
    return


#endregion

############################################################
resetAllModifications = ->
    deleteConfirmation.turnDownModal("uiState changed")
    input.reset()
    unlock.reset()
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

applyModifier["phraseinput"] = () ->
    resetAllModifications()
    input.retrievePhrase()
    return

applyModifier["qrinput"] = () ->
    resetAllModifications()
    input.retrieveQrCode()
    return

applyModifier["qrunlock"] = () ->
    resetAllModifications()
    unlock.qrUnlock()
    return

applyModifier["phraseunlock"] = () ->
    resetAllModifications()
    unlock.phraseUnlock()
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