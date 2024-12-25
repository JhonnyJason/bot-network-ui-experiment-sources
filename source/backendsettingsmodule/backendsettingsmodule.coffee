############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("backendsettingsmodule")
#endregion

############################################################
import { RPCPostClient } from "thingy-post-rpc-client"

############################################################
import * as S from "./statemodule.js"
import * as utl from "./utilsmodule.js"
import * as account from "./accountmodule.js"
import * as cfg from "./configmodule.js"
import * as msgBox from "./messageboxmodule.js"

############################################################
# import * as backend from "./backendmodule.js"

############################################################
currentInputValue = ""
currentBackendURL = ""
currentBackendId = ""
currentExpectedId = ""
noStatedId = "-"

############################################################
storedBackendObject = null

############################################################
export initialize = ->
    log "initialize"
    backendServerInput.addEventListener("keydown", serverInputKeyDowned)
    backendServerInput.addEventListener("keyup", serverInputKeyUpped)
    backendServerInput.addEventListener("change", serverInputChanged)

    backendServerSaveButton.addEventListener("click", saveButtonClicked)
    backendServerResetButton.addEventListener("click", resetButtonClicked)

    storedBackendObject = S.load("backendStoreObject")
    if storedBackendObject and storedBackendObject.url
        backendServerInput.value = storedBackendObject.url
        currentInputValue = storedBackendObject.url
        currentBackendURL = storedBackendObject.url

        # currentExpectedId = storedBackendObject.id
        # backendExpectedServerIdInput.value = currentExpectedIds 
        if storedBackendObject.id then backendStatedServerId.textContent = storedBackendObject.id
        else backendStatedServerId.textContent = noStatedId
    else
        backendServerInput.value = ""
        currentInputValue = ""
        currentBackendURL = ""
        backendStatedServerId.textContent = noStatedId
        storedBackendObject = {
            url: "",
            id: ""
        }

    olog storedBackendObject
    S.addOnChangeListener("account", accountChanged)
    return



############################################################
accountChanged = ->
    log "accountChanged"
    checkConnection()
    return

############################################################
createRPCClient = (url, id) ->
    log "createRPCClient"
    node = account.getCryptoNode()

    if url and !url.endsWith("/thingy-post-rpc") then url = "#{url}/thingy-post-rpc"

    olog node

    if node? and node.key?
        options = {
            serverURL: url
            serverId: id
            secretKeyHex: node.key
        }
        olog options
        return new RPCPostClient(options)
    else return null
    return


############################################################
saveButtonClicked = ->
    log "saveButtonClicked"
    storedBackendObject = {
        url: currentBackendURL
        id: currentBackendId
    }

    currentExpectedId = currentBackendId
    S.save("backendStoreObject", storedBackendObject, true)
    msgBox.info("Successfully Saved Server Connection!")
    return

resetButtonClicked = ->
    log "resetButtonClicked"
    backendServerInput.value = storedBackendObject.url
    currentInputValue = storedBackendObject.url
    currentBackendURL = storedBackendObject.url

    if storedBackendObject.id then backendStatedServerId.textContent = storedBackendObject.id
    else backendStatedServerId.textContent = noStatedId
    checkConnection()
    msgBox.info("Successfully Resetted to latest Saved Data!")

    return


############################################################
serverInputChanged = ->
    log "serverInputChanged"
    currentInputValue = backendServerInput.value
    log currentInputValue

    if !currentInputValue.startsWith("https://")
        currentBackendURL = "https://#{currentInputValue}"
    else currentBackendURL = currentInputValue

    checkConnection()
    return

checkConnection = ->
    log "checkConnection"
    try
        rpcClient = createRPCClient(currentBackendURL, currentExpectedId)
        log "created RPC client"
        await rpcClient.requestNodeId("clientSignature")
        realServerId = await rpcClient.getServerId("clientSignature")
        log "requested ServerId"
        ## we must have the correct serverID here!
        currentBackendId = realServerId
        backendStatedServerId.textContent = currentBackendId 
        backendInputContainer.className = "connected"
        
        log "assigned the real ServerId"
    catch err
        log err
        currentBackendId = ""
        backendStatedServerId.textContent = noStatedId
        backendInputContainer.className = "connection-fail"
        
        log "applied failed connection!"

############################################################
serverInputKeyDowned = (evnt) ->
    log "serverInputKeyDowned"
    
    if evnt.key == "Escape"
        backendServerInput.value = currentInputValue
        backendInputContainer.classList.remove("typing")
        backendServerInput.blur()
        return


    unappliedChange = (currentInputValue != backendServerInput.value) 

    if unappliedChange then backendInputContainer.classList.add("typing")
    else backendInputContainer.classList.remove("typing")

    return

serverInputKeyUpped = ->
    log "serverInputKeyUpped"
    unappliedChange = (currentInputValue != backendServerInput.value) 
    inputValue = backendServerInput.value
    olog {unappliedChange, inputValue, currentInputValue}

    if unappliedChange then backendInputContainer.classList.add("typing")
    else backendInputContainer.classList.remove("typing")

    return


