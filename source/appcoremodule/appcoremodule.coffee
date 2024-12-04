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
import * as localKey from "./localkeymodule.js"

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
loadWithNavState = (navState) ->
    log "loadWithNavState"
    olog navState
    if !localKey.isSet() and navState.depth != 0 then return triggers.reset()
    else updateNavState(navState)
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
        if localKey.isSet() then base = "global-overview"
        else base = "no-key"

    setAppState(base, mod, ctx)

    ## modifiers here as they might be involved with user-interactions
    ## Current version of handling user interaction is split between the process of the appcore and the view setup in the uistate
    ## setAppState sets the uistate and might reset any state involved with the userinteraction - uistate is responsible to make the appropriate parts visible
    ## Thus the appcore sets the state according to the state involved with the userinteraction as any further action of the App depends on it

    if mod == "delete-confirmation" then deleteConfirmationProcess(ctx)
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
        if !ctx.index? then throw new Error("called deleteConfirmationProcess without server index to delete")

        await deleteConfirmation.userConfirmation()
        log "user confirmed!"
        await servers.deleteServer(ctx.index)
        log "server deleted!"
    catch err then log err
    finally triggers.mainView()
    return

urlCodeDetectedProcess = ->
    log "urlCodeDetectedProcess"
    log "urlCode is: #{urlCode}"
    try
        credentials = await verificationModal.pickUpConfirmedCredentials(urlCode)
        await account.addValidAccount(credentials)
    catch err then log err
    finally nav.toRoot(true)
    return

#endregion