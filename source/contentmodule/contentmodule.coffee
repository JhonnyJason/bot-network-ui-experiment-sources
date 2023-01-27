############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("contentmodule")
#endregion

############################################################
import { createClient } from "./authclientmodule.js"
import * as state from "./statemodule.js"
import { info, error } from "./messageboxmodule.js"

############################################################
masterClient = null

############################################################
export initialize = ->
    log "initialize"

    ## Master Functions
    addClientButton.addEventListener("click", addClientButtonClicked)
    removeClientButton.addEventListener("click", removeClientButtonClicked)
    getClientsButton.addEventListener("click", getClientsButtonClicked)

    ## Client Setup
    secretKeyHex = state.get("secretKeyHex")
    serverURL = "https://localhost:6969"
    o = {serverURL, secretKeyHex}
    
    masterClient = createClient(o)
    return

############################################################
addClientButtonClicked = (evnt) ->
    log "addClientButtonClicked"
    try
        clientId = clientIdInput.value
        reply = await masterClient.addClient(clientId)
        olog reply
        info("ADD appearently successful!")
    catch err 
        m = "Error on trying to add a new client: #{err.message}"
        log(m)
        error(m)
    return

removeClientButtonClicked = (evnt) ->
    log "removeClientButtonClicked"
    try
        clientId = clientIdInput.value
        reply = await masterClient.removeClient(clientId)
        olog {reply}
        info("REMOVE appearently successful!")

    catch err 
        m = "Error on trying to remove client: #{err.message}"
        error(m)
        log(m)     
    return

getClientsButtonClicked = (evnt) ->
    log "getClientsButtonClicked"
    try
        clients = await masterClient.getClients() 
        olog {clients}
        info("GETCLIENTS appearently successful!")

        html = ""
        for client in clients
            html += "<li>#{client}</li>"
        clientsToServeList.innerHTML = html

    catch err
        m = "Error on retrieveing clients to serve: #{err.message}"
        log(m)
        error(m)
    return
