############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("masterkeymodule")
#endregion

############################################################
import { ThingyCryptoNode } from "thingy-crypto-node"
import { RPCAuthMasterClient } from "thingy-rpc-authmaster-client"
import * as secUtl from "secret-manager-crypto-utils"

############################################################
import * as utl from "./utilsmodule.js"
import * as alias from "./aliasmodule.js"
import * as msgBox from "./messageboxmodule.js"
import * as triggers from "./navtriggers.js"

############################################################
#region internal variables

cryptoNode = null
context = "Auth Master UI" 

############################################################
masterKey = ""
masterKeyId = ""
masterKeyAlias = ""

############################################################
storageId = ""

############################################################
floatingSecretBaseClassName = ""
currentFloatingSecret = ""

aliasBaseClassName = ""
currentAlias = ""

############################################################
allAuthMasterClients = new Map()

#endregion

############################################################
export initialize = ->
    log "initialize"
    floatingSecretInput.addEventListener("change", floatingSecretChanged)
    floatingSecretInput.addEventListener("keyup", floatingSecretKeyUpped)
    # floatingSecretInput.addEventListener("keydown", floatingSecretKeyDowned)
    aliasInput.addEventListener("change", aliasChanged)
    aliasInput.addEventListener("keyup", aliasKeyUpped)
    aliasInput.addEventListener("keydown", aliasKeyDowned)

    acceptUseButton.addEventListener("click", acceptButtonClicked)
    masterkeydisplay.addEventListener("click", keyDisplayClicked)
    return

############################################################
keyDisplayClicked = ->
    log "keyDisplayClicked"
    content.className = "set-master-key"
    return

acceptButtonClicked = ->
    log "acceptButtonClicked"
    triggers.mainView()
    return

############################################################
floatingSecretKeyUpped = ->
    log "floatingSecretKeyUpped"
    if currentFloatingSecret == floatingSecretInput.value
        floatingSecretInput.className = floatingSecretBaseClassName
    else
        floatingSecretInput.className = "typing"
    return

aliasKeyUpped = ->
    log "aliasKeyUpped"
    if currentAlias == aliasInput.value
        aliasInput.className = aliasBaseClassName
    else
        aliasInput.className = "typing"    
    return

aliasKeyDowned = (evnt) ->
    if evnt.key == "Enter" then acceptButtonClicked()
    return

############################################################
floatingSecretChanged = ->
    log "floatingSecretChanged"

    floatingSecretInput.className = "okay"
    floatingSecretBaseClassName = "okay"
    currentFloatingSecret = floatingSecretInput.value

    masterKey = await utl.seedToKey(currentFloatingSecret)
    masterKeyId = await secUtl.createPublicKey(masterKey)
    storageId = await secUtl.sha256Hex("#{context}_#{masterKeyId}")
    options = {
        secretKeyHex: masterKey
        publicKeyHex: masterKeyId
        context: context
    }
    cryptoNode = new ThingyCryptoNode(options)

    await alias.loadForStorageId(storageId)
    masterKeyAlias = alias.getAliasForId(masterKeyId)
    
    activateAndFillBottomGroup()
    updateMasterKeyHeadline()
    aliasInput.focus()
    return

aliasChanged = ->
    log "aliasChanged"
    currentAlias = aliasInput.value
    masterKeyAlias = currentAlias

    try 
        alias.setAliasForId(masterKeyAlias, masterKeyId)
        aliasInput.className = "okay"
        aliasBaseClassName = "okay"
    catch err
        log err
        msgBox.error(err.message)
        aliasInput.className = "error"
        aliasBaseClassName = "error"
    
    updateMasterKeyHeadline()
    return

############################################################
activateAndFillBottomGroup = ->
    log "activateAndFillBottomGroup"
    passiveGroup = document.getElementsByClassName("passive")[0]
    if passiveGroup? then passiveGroup.classList.remove("passive")

    keyIdDisplay.innerHTML = "0x#{masterKeyId}"
    storageIdDisplay.innerHTML = "#{storageId}"
    if masterKeyAlias then aliasInput.value = masterKeyAlias
    else 
        aliasInput.setAttribute("placeholder", "Define Alias")
        aliasInput.value = ""

    return

updateMasterKeyHeadline = ->
    log "updateMasterKeyHeadline"
    masterkeyAlias.innerHTML = masterKeyAlias
    masterkeyId.innerHTML = "0x#{masterKeyId}"
    masterkeyStorageId.innerHTML = storageId    
    return

############################################################
export isSet = -> cryptoNode?

############################################################
export encrypt = (content) -> cryptoNode.encrypt(content)

export decrypt = (encrypted) -> cryptoNode.decrypt(encrypted)

############################################################
export getAuthMasterClient = (serverURL, serverId) ->
    serverURL = "#{serverURL}/thingy-post-rpc"
    mapKey = "#{serverId}:#{serverURL}"

    client = allAuthMasterClients.get(mapKey)
    if client? then return client

    secretKeyHex = cryptoNode.key
    publicKeyHex = cryptoNode.id

    options = {serverURL, serverId, secretKeyHex, publicKeyHex}
    
    olog options

    client = new RPCAuthMasterClient(options)
    allAuthMasterClients.set(mapKey, client)
    return client

############################################################
export getStorageId = -> storageId

############################################################
export focusFloatingSecretInput = ->
    floatingSecretInput.focus()
    return