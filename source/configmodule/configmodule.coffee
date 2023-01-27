
############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("configmodule")
#endregion

########################################################
export initialize = ->
    log "initialize"
    return    

############################################################
# Secret Manager
export secretManagerOptions = [
    "https://secrets.dotv.ee",
    "https://secrets-dev.dotv.ee",
    "https://secrets.extensivlyon.coffee"
]
export defaultSecretManagerChoice = 0

############################################################
# Secret Manager
export dataManagerOptions = [
    "https://data.dotv.ee",
    "https://data-dev.dotv.ee",
    "https://data.extensivlyon.coffee"
]
export defaultDataManagerChoice = 1

############################################################
# StrunFun Backend
export backendOptions = [
    "https://kraken-observer.dotv.ee",
    "https://kraken-observer.extensivlyon.coffee"
    "https://localhost:6999"
]
export defaultBackendChoice = 2
