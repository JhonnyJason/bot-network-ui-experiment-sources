############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("datamodule")
#endregion

############################################################
import * as sampleData from "./sampledata.js"

############################################################
import * as S from "./statemodule.js"
import * as account from "./accountmodule.js"
import * as exchangeData from "./exchangedata.js"
import * as controllerData from "./controllerdata.js"
import { afExchanges } from "./afexchanges.js"
import { afControllers } from "./afcontrollers.js"


############################################################
typeToBaseExchangeObj = {}
typeToBaseControllerObj = {}

############################################################
export initialize = ->
    exchangeData.initialize()
    controllerData.initialize()

    S.addOnChangeListener("account", syncAllData)
    syncAllData()
    return

############################################################
syncAllData = ->
    log "loadAllData"
    exchangeData.syncExchangeData()
    controllerData.syncControllerData()
    return 

############################################################
export loadEncryptedData = (dataLabel) ->
    log "loadEncryptedData"
    keyInfo = account.getKeyInfo()
    node = account.getCryptoNode()
    encryptedData = S.load(dataLabel)

    olog {node, encryptedData}
    
    keyReady = (keyInfo? and keyInfo.exists and !keyInfo.locked and node?)
    validData = (encryptedData? and encryptedData.referencePointHex? and encryptedData.encryptedContentHex?)
    
    tryDecrypt = (keyReady and validData)
    if !tryDecrypt then return null

    try 
        decryptedString  = await node.decrypt(encryptedData)
        log decryptedString
        return JSON.parse(decryptedString)
    catch err then log err

    return null

export saveDataEncrypted = (dataLabel, dataObj) ->
    log "saveDataEncrypted"
    node = account.getCryptoNode()
    return unless node?
    
    try
        dataString = JSON.stringify(dataObj)
        encryptedData = await node.encrypt(dataString)
        olog encryptedData
        S.save(dataLabel, encryptedData, true)
    catch err then log err
    return


