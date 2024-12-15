############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountmodule")
#endregion

############################################################
import { ThingyCryptoNode } from "thingy-crypto-node"
import * as secUtl from "secret-manager-crypto-utils"

############################################################
#region modulesFromEnvironment
import * as S from "./statemodule.js"
import * as utl from "./utilsmodule.js"
import * as accountSettings from "./accountsettingsmodule.js"

############################################################
import { cryptoContext } from "./configmodule.js"

#endregion

############################################################
#region internalVariables
currentCryptoNode = null
currentKeyObj = null

############################################################
currentKeyInfo = {
    exists: false
    locked: false
    protection: "none"
}

#endregion

############################################################
export initialize = ->
    log "initialize"
    readKeyObject()
    postKeyChange()
    return

############################################################
#region internalFuntions

############################################################
postKeyChange = ->
    log "postKeyChange"
    olog currentKeyObj

    generateKeyInfo()    
    olog currentKeyInfo

    createCurrentCryptoNode()
    updateDisplay()
    S.callOutChange("account")
    return

############################################################
#region keyReading Function
readKeyObject = ->
    log "readKeyObject"
    keyStoreObj = S.load("keyStoreObject")
    olog keyStoreObj

    if !keyStoreObj? or Object.keys(keyStoreObj).length != 5
        currentCryptoNode = null
        currentKeyObj = null
        return

    publicKeyHex = keyStoreObj.accountIdHex
    secretKeyHex = keyStoreObj.secretKeyHex
    keyTraceHex = keyStoreObj.keyTraceHex
    keySaltHex = keyStoreObj.keySaltHex
    protection = keyStoreObj.protection

    if publicKeyHex and !utl.isValidKey(publicKeyHex) then throw new Error("Read a publicKey of invalid Format!")
    if secretKeyHex and !utl.isValidKey(secretKeyHex) then throw new Error("Read a secretKey of invalid Format!")
    if keyTraceHex and !utl.isValidKey(keyTraceHex) then throw new Error("Read a keyTrace of invalid Format!") 

    currentKeyObj = { secretKeyHex, publicKeyHex, protection, keyTraceHex, keySaltHex }
    return

############################################################
generateKeyInfo = ->
    log "generateKeyInfo"
    if !currentKeyObj?
        currentKeyInfo.exists = false
        currentKeyInfo.locked = false
        currentKeyInfo.protection = "none"
        return

    currentKeyInfo.exists = true
    currentKeyInfo.protection = currentKeyObj.protection

    if currentKeyInfo.protection != "none" and !currentKeyObj.secretKeyHex
        currentKeyInfo.locked = true
        return

    currentKeyInfo.locked = false
    return

############################################################
createCurrentCryptoNode = ->
    log "createCurrentCryptoNode"
    if !currentKeyObj? then return currentCryptoNode = null
    if !currentKeyObj.secretKeyHex? then return currentCryptoNode = null

    try
        options = {
            secretKeyHex: currentKeyObj.secretKeyHex
            publicKeyHex: currentKeyObj.publicKeyHex
            context: cryptoContext
        }
        currentCryptoNode = new ThingyCryptoNode(options)
    catch err then log err
    return

############################################################
updateDisplay = ->
    log "updateDisplay"
    if currentKeyInfo.exists then keyIdHex = utl.add0x(currentKeyObj.publicKeyHex)
    else keyIdHex = ""

    accountSettings.displayKeyId(keyIdHex)
    return

#endregion


############################################################
#region keyWriting Functions
storeKeyObject = ->
    log "storeKeyObject"
    if currentKeyObj.protection == "none" then secretKeyHex =  currentKeyObj.secretKeyHex
    else secretKeyHex = ""

    keyStoreObj = {
        secretKeyHex: secretKeyHex
        accountIdHex: currentKeyObj.publicKeyHex
        protection: currentKeyObj.protection
        keySaltHex: currentKeyObj.keySaltHex
        keyTraceHex: currentKeyObj.keyTraceHex
    }

    S.save("keyStoreObject", keyStoreObj)
    return

############################################################
useUnprotectedKey = (fullKeyHandle) ->
    log "useUnprotectedKey"
    olog fullKeyHandle

    secretKeyHex = fullKeyHandle.secretKeyHex
    publicKeyHex = fullKeyHandle.publicKeyHex
    protection = fullKeyHandle.protection
    keyTraceHex = ""
    keySaltHex = ""

    currentKeyObj = { secretKeyHex, publicKeyHex, protection, keyTraceHex, keySaltHex }

    postKeyChange()
    return

useProtectedKey = (fullKeyHandle) ->
    log "useProtectedKey"
    olog fullKeyHandle

    secretKeyHex = fullKeyHandle.secretKeyHex
    publicKeyHex = fullKeyHandle.publicKeyHex
    protection = fullKeyHandle.protection
    keyTraceHex = fullKeyHandle.keyTraceHex
    keySaltHex = fullKeyHandle.keySaltHex

    currentKeyObj = { secretKeyHex, publicKeyHex, protection, keyTraceHex, keySaltHex }

    postKeyChange()
    return

#endregion

#endregion

############################################################
#region exportedFunctions
export getCryptoNode = -> currentCryptoNode
export hasKey = -> currentKeyInfo.exists
export isLocked = -> currentKeyInfo.locked
export keyIsLocked = -> currentKeyInfo.locked
export getKeyInfo = -> currentKeyInfo

############################################################
export deleteAccount = ->
    log "deleteAccount"
    S.remove("keyStoreObject")

    currentCryptoNode = null
    currentKeyObj = null

    postKeyChange()
    return

############################################################
export useNewKey = (fullKeyHandle) ->
    log "useNewKey"
    if fullKeyHandle.protection == "none" then useUnprotectedKey(fullKeyHandle)
    else useProtectedKey(fullKeyHandle)
    storeKeyObject()
    return

############################################################
export unlockKey = (secretData) ->
    log "unlockKey"
    keySaltHex = currentKeyObj.keySaltHex
    seed = keySaltHex + secretData

    splitterKeyHex = await utl.seedToKey(seed)
    keyTraceHex = currentKeyObj.keyTraceHex

    secretKeyHex = utl.hexXOR(splitterKeyHex, keyTraceHex)

    publicKeyHex = await secUtl.createPublicKeyHex(secretKeyHex)

    if publicKeyHex != currentKeyObj.publicKeyHex 
        throw new Error("Error in Key Unlock!")

    currentKeyObj.secretKeyHex = secretKeyHex
    postKeyChange()
    return

#endregion