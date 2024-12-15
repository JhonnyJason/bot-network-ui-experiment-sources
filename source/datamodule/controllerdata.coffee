############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("exchangedata")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as data from "./datamodule.js"
import { afControllers } from "./afcontrollers.js"

############################################################
#region internalVariables
allControllerData = []
controllerStore = []

############################################################
dataSynced = false
isSyncing = false

############################################################
typeToBaseControllerObj = {}

#endregion

############################################################
export initialize = ->
    typeToBaseControllerObj[ctlr.type] = ctlr for ctlr in afControllers
    return

############################################################
#region internalFunctions
storeToDataObj = (storeObj) ->
    dataObj = {}
    dataObj.type = storeObj.type
    baseObj = typeToBaseControllerObj[storeObj.type]
    dataObj = Object.assign(dataObj, baseObj)
    if storeObj.name? then dataObj.name = storeObj.name
    return dataObj

saveAllControllerData = ->
    log "saveAllControllerData"    
    olog controllerStore
    await data.saveDataEncrypted("encryptedControllerData", controllerStore)
    return

#endregion

############################################################
#region exposedFunctions
export syncControllerData = ->
    log "syncControllerData"
    return if isSyncing

    controllerStore = []
    allControllerData = []
    dataSynced = false
    isSyncing = true

    try
        storedData = await data.loadEncryptedData("encryptedExchangeData")
        ## TODO request Data from Backend 
        mergedData = storedData ## TODO real merge

        allControllerData = mergedData.map(storeToDataObj)
        controllerStore = mergedData
    catch err then log err    

    isSyncing = false
    dataSynced = true
    S.callOutChange("controllerData")
    return

############################################################
export getControllerData = ->
    await syncControllerData() unless dataSynced 
    return allControllerData 

export getController = (index) ->
    await syncControllerData() unless dataSynced
    return allControllerData[index]

############################################################
export addController = (storeObj) ->
    log "addController"
    ## TODO Connect With Backend to get Exchange Data    
    if !dataSynced then await syncControllerData()

    controllerStore.push(storeObj)
    allControllerData.push(storeToDataObj(storeObj))

    await saveAllExchangesData()

    S.callOutChange("controllerData")
    return

#endregion