############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("contentmodule")
#endregion

############################################################
# import { createClient as createRPCClient } from "./rpcclientmodule.js"
# import { createClient as createAuthClient } from "./authclientmodule.js"
# import { createClient as createObserverClient } from "./observerclientmodule.js"
import { RPCAuthMasterClient } from "thingy-rpc-authmaster-client"
import * as state from "./statemodule.js"
import { info, error } from "./messageboxmodule.js"
import * as cryptoUtl from "secret-manager-crypto-utils"

############################################################
masterClient = null
observerClient = null

############################################################
export initialize = ->
    log "initialize"

    ## Authentications: Master Functions
    addClientButton.addEventListener("click", addClientButtonClicked)
    removeClientButton.addEventListener("click", removeClientButtonClicked)
    getClientsButton.addEventListener("click", getClientsButtonClicked)

    ## Observer: Regular Operations
    latestOrdersButton.addEventListener("click", latestOrdersButtonClicked)
    latestTickersButton.addEventListener("click", latestTickersButtonClicked)
    latestBalancesButton.addEventListener("click", latestBalancesButtonClicked)

    ## TODO remove this code - just for testing
    ## Client Setup
    secretKeyHex = state.get("secretKeyHex")
    if !secretKeyHex? 
        keyPairHex = await cryptoUtl.createKeyPairHex()
        state.save("secretKeyHex", keyPairHex.secretKeyHex)
        state.save("publicKeyHex", keyPairHex.publicKeyHex)
        secretKeyHex = keyPairHex.secretKeyHex

    publicKeyHex = state.get("publicKeyHex")
    serverURL = "https://localhost:6969/thingy-post-rpc"
    serverId = "a8d9607f6cc919af3df3850084f63c9536efea790b3f80f514717d2a3a0159e6"
    # options = { serverURL, secretKeyHex }
    options = { serverURL, serverId,  secretKeyHex, publicKeyHex }
    
    masterClient = new RPCAuthMasterClient(options)
    return

############################################################
addClientButtonClicked = (evnt) ->
    log "addClientButtonClicked"
    try
        clientId = clientIdInput.value
        reply = await masterClient.addClient(clientId)
        olog {reply}
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


############################################################
latestOrdersButtonClicked = (evnt) ->
    log "latestOrdersButtonClicked"
    try
        reply = await observerClient.getLatestOrders("aave-euro")
        displayRegularOperationsResponseContainer.textContent = JSON.stringify(reply, null, 4)
        olog reply
        info("getLatestOrders appearently successful!")
    catch err 
        m = "Error on trying to getLatestOrders: #{err.message}"
        log(m)
        error(m)
    return

latestTickersButtonClicked = (evnt) ->
    log "latestTickersButtonClicked"
    try
        reply = await observerClient.getLatestTickers("aave-euro")
        displayRegularOperationsResponseContainer.textContent = JSON.stringify(reply, null, 4)
        olog reply
        info("getLatestTickers appearently successful!")
    catch err 
        m = "Error on trying to getLatestTickers: #{err.message}"
        log(m)
        error(m)
    return

latestBalancesButtonClicked = (evnt) ->
    log "latestBalancesButtonClicked"
    try
        reply = await observerClient.getLatestBalances("euro")
        displayRegularOperationsResponseContainer.textContent = JSON.stringify(reply, null, 4)
        olog reply
        info("getLatestBalances appearently successful!")
    catch err 
        m = "Error on trying to getLatestBalances: #{err.message}"
        log(m)
        error(m)
    return

