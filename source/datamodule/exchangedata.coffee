############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("exchangedata")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as data from "./datamodule.js"
import { afExchanges } from "./afexchanges.js"

############################################################
#region internalVariables
allExchangeData = []
exchangeStore = []

############################################################
dataSynced = false
isSyncing = false
dataHasSynced = null
syncResolve = null

############################################################
typeToBaseExchangeObj = {}

#endregion

############################################################
export initialize = ->
    typeToBaseExchangeObj[exch.type] = exch for exch in afExchanges
    return

############################################################
#region internalFunctions
storeToDataObj = (storeObj) ->
    dataObj = {}
    dataObj.type = storeObj.type
    baseObj = typeToBaseExchangeObj[storeObj.type]
    dataObj = Object.assign(dataObj, baseObj)
    if storeObj.name? then dataObj.name = storeObj.name
    return dataObj

saveAllExchangesData = ->
    log "saveAllExchangesData"    
    olog exchangeStore
    await data.saveDataEncrypted("encryptedExchangeData", exchangeStore)
    return

#endregion

############################################################
#region exposedFunctions
export syncExchangeData = ->
    log "syncExchangeData"

    return await dataHasSynced if isSyncing

    dataHasSynced = new Promise((resolve) -> syncResolve = resolve)
    isSyncing = true

    dataSynced = false
    exchangeStore = []
    allExchangeData = []

    try
        storedData = await data.loadEncryptedData("encryptedExchangeData")
        ## TODO request Data from Backend 
        mergedData = storedData ## TODO real merge

        allExchangeData = mergedData.map(storeToDataObj)
        exchangeStore = mergedData
    catch err then log err    

    isSyncing = false
    dataSynced = true
    syncResolve()
    S.callOutChange("exchangeData")
    return

############################################################
export getExchangeData = ->
    await syncExchangeData() unless dataSynced 
    return allExchangeData 

export getExchange = (index) ->
    await syncExchangeData() unless dataSynced
    return allExchangeData[index]

############################################################
export addExchange = (storeObj) ->
    log "addExchange"
    ## TODO Connect With Backend to get Exchange Data    
    if !dataSynced then await syncExchangeData()

    exchangeStore.push(storeObj)
    allExchangeData.push(storeToDataObj(storeObj))

    await saveAllExchangesData()

    S.callOutChange("exchangeData")
    return

#endregion