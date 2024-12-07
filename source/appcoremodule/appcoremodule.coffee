############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("appcoremodule")
#endregion

############################################################
import * as nav from "navhandler"
import * as S from "./statemodule.js"

############################################################
import * as uiState from "./uistatemodule.js"
import * as triggers from "./navtriggers.js"
import * as account from "./accountmodule.js"

############################################################
import * as deleteConfirmation from "./deleteconfirmation.js"
import * as keyGeneration from "./keygeneration.js"
import * as keyImport from "./keyimport.js"
import * as keyExport from "./keyexport.js"

############################################################
import { appVersion } from "./configmodule.js"

############################################################
serviceWorker = null
if navigator? and navigator.serviceWorker?
    serviceWorker = navigator.serviceWorker

############################################################
currentVersion = document.getElementById("current-version")
newVersion = document.getElementById("new-version")
menuVersion = document.getElementById("menu-version")

############################################################
appBaseState = "no-key"
appUIMod = "none"

############################################################
export initialize = ->
    log "initialize"
    nav.initialize(loadWithNavState, updateNavState, false)

    if currentVersion? then currentVersion.textContent = appVersion

    if serviceWorker?
        serviceWorker.register("serviceworker.js", {scope: "/"})
        if serviceWorker.controller?
            serviceWorker.controller.postMessage("App is version: #{appVersion}!")
        serviceWorker.addEventListener("message", onServiceWorkerMessage)
        serviceWorker.addEventListener("controllerchange", onServiceWorkerSwitch)

    return

############################################################
alterStateOnLoad = (navState) ->
    log "alterStateOnLoad"
    s = navState
    
    ki = account.getKeyInfo()

    olog ki

    ## case: key exists and locked -> alter state
    if ki.exists and ki.locked 
        switch ki.protection 
            when "qr" then triggers.unlockWithQR()
            when "phrase" then triggers.unlockWithPhrase()
            else throw new Error("Unhandeled protection value: #{ki.protection}")
        log "Key Existed and was Protected!"
        return true

    ## case: key exists and unlocked -> all good
    if ki.exists then return false

    log "Key did not exist!"

    ## case: no key + legal state -> all good
    ## legal: RootState (depth: 0)
    ## legal: settings (depth: 1)
    ## legal: settings-account (depth:1 or depth: 2)
    ## legal: settings-backend (depth: 2)
    ## legal: settings-account-keygeneration (depth: 2 or depth: 3)
    ## legal: settings-account-keyimport (depth: 2 or depth: 3)
    switch s.base
        when "RootState" then legal = (s.depth == 0)
        when "settings" then legal = (s.depth == 1)
        when "settings-backend" then legal = (s.depth == 2)
        when "settings-account" then legal = (s.depth == 1 or s.depth == 2)
        when "settings-account-keygeneration" then legal = (s.depth == 2 or s.depth == 3)
        when "settings-account-keyimport" then legal = (s.depth == 2 or s.depth == 3)
        else legal = false
    
    if legal then return false

    log "We are in an illegal State!"

    ## case: no key + illegal state -> alter state
    triggers.reset()
    return true


############################################################
loadWithNavState = (navState) ->
    log "loadWithNavState"
    olog navState
    if alterStateOnLoad(navState) then return
    
    updateNavState(navState)
    return

############################################################
updateNavState = (navState) ->
    log "navStateUpdate"
    baseState = navState.base
    modifier = navState.modifier
    context = navState.context
    S.save("navState", navState)

    setUIState(baseState, modifier, context)
    return


############################################################
#region internal Functions
setUIState = (base, mod, ctx) ->
    log "setUIState"
    olog {base, mod, ctx}

    ## If we are in RootState we might have a key so we have 2 overlapping initial states
    if base == "RootState" 
        if account.hasKey() then base = "global-overview"
        else base = "no-key"

    setAppState(base, mod, ctx)

    ## modifiers here as they might be involved with user-interactions
    ## Current version of handling user interaction is split between the process of the appcore and the view setup in the uistate
    ## setAppState sets the uistate and might reset any state involved with the userinteraction - uistate is responsible to make the appropriate parts visible
    ## Thus the appcore sets the state according to the state involved with the userinteraction as any further action of the App depends on it

    switch mod
        when "deleteconfirmation" then deleteConfirmationProcess()
        when "keygeneration" then keyGenerationProcess()
        when "keyimport" then keyImportProcess()
        when "keyexport" then keyExportProcess()

    return

############################################################
updateUIData = ->
    log "updateUIData"
    # update data in the UIs
    menuModule.updateAllUsers()
    codeDisplay.updateCode()
    usernameDisplay.updateUsername()
    return

############################################################
setAppState = (base, mod, ctx) ->
    log "setAppState"
    olog {base, mod, ctx}

    if base then appBaseState = base
    if mod then appUIMod = mod
    
    log "Going to apply UI State: #{appBaseState}:#{appUIMod}"
    
    uiState.applyUIState(appBaseState, appUIMod, ctx)
    return
    
############################################################
onServiceWorkerMessage = (evnt) ->
    log("  !  onServiceWorkerMessage")
    if typeof evnt.data == "object" and evnt.data.version?
        serviceworkerVersion = evnt.data.version
        # olog { appVersion, serviceworkerVersion }
        if serviceworkerVersion == appVersion then return
        newVersion.textContent = serviceworkerVersion
        menuVersion.classList.add("to-update")
    return

onServiceWorkerSwitch = ->
    # console.log("  !  onServiceWorkerSwitch")
    serviceWorker.controller.postMessage("Hello I am version: #{appVersion}!")
    serviceWorker.controller.postMessage("tellMeVersion")
    return
    
#endregion

############################################################
#region User Interaction Processes
deleteConfirmationProcess = (ctx) ->
    log "deleteConfirmationProcess"
    try
        await deleteConfirmation.userConfirmation()
        log "user confirmed!"
        account.deleteAccount()
        log "account deleted!"
    catch err then log err
    finally nav.toMod("none")    
    return

#endregion