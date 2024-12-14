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

############################################################
allExchanges = []

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return

############################################################
export addExchange = (aeObj) ->
    log "addExchange"
    ## TODO send API Keys to server and verify connection
    addObject = {}

    if aeObj.type == "kraken"
        addObject.name = "Kraken"
        addObject.iconHref = "#svg-kraken-icon"
        
    if aeObj.type == "binance"
        addObject.name = "Binance"
        addObject.iconHref = "#svg-binance-icon"

    addObject.currentEvaluation = 0

    allExchanges.push(addObject)
    
    saveAllExchangesData()
    return

############################################################
export getAllExchangesData = ->
    log "getAllExchangesData"

    ## For testing
    return []
    return sampleData.allExchanges


    keyInfo = account.getKeyInfo()
    node = account.getCryptoNode()
    encryptedData = S.load("encryptedExchangeData")
    
    # encryptedData = {
    #     referencePointHex:"d2dfbcc5d925f095018d48d0606aeb5c64502ce8d7209be0db532d981c67e4be",
    #     encryptedContentHex:"e575a31aa198bd0bb93e9fd63ab42a9ed6c03a246b2eccbfd88144a8be9ad7dc23bcbbf618257ccb01f113859adfa99b1f823f478bf4254870df992f8ad5892cc9a508b47d9e983c427904854bf812f698f8b6ef467dbe6a526f1bcf416154a6a98622f52d871d1a55974b25554fed19202fc120bed28cb39439cd28437bcd0ae344a68417254ec45ca6ad8f90df28f0"
    # }

    olog {node, encryptedData}
    
    keyReady = (keyInfo? and keyInfo.exists and !keyInfo.locked and node?)
    validData = (encryptedData? and encryptedData.referencePointHex? and encryptedData.encryptedContentHex?)
    tryDecrypt = (keyReady and validData)
    
    if !tryDecrypt then return []

    try 
        decryptedString  = await node.decrypt(encryptedData)
        log decryptedString
        allExchanges = JSON.parse(decryptedString)
        return allExchanges
    catch err then log err
    return []


saveAllExchangesData = (newAllExchanges) ->
    log "saveAllExchangesData"    
    if newAllExchanges? then allExchanges = newAllExchanges

    node = account.getCryptoNode()
    return unless node?
    
    allExchangesString = JSON.stringify(allExchanges)
    
    try
        encryptedData = await node.encrypt(allExchangesString)
        S.save("encryptedExchangeData", encryptedData, true)
    catch err then log err
