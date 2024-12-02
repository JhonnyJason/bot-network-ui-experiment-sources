############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("functiontestermodule")
#endregion

############################################################
export initialize = ->
    log "initialize"

    ## Observer: Regular Operations
    latestOrdersButton.addEventListener("click", latestOrdersButtonClicked)
    latestTickersButton.addEventListener("click", latestTickersButtonClicked)
    latestBalancesButton.addEventListener("click", latestBalancesButtonClicked)


    ## TODO remove this code - just for testing
    ## Client Setup
    # secretKeyHex = state.get("secretKeyHex")
    # if !secretKeyHex?
    #     keyPairHex = await cryptoUtl.createKeyPairHex()
    #     state.save("secretKeyHex", keyPairHex.secretKeyHex)
    #     state.save("publicKeyHex", keyPairHex.publicKeyHex)
    #     secretKeyHex = keyPairHex.secretKeyHex

    # publicKeyHex = state.get("publicKeyHex")
    # serverURL = "https://localhost:6969/thingy-post-rpc"
    # # serverId = "a8d9607f6cc919af3df3850084f63c9536efea790b3f80f514717d2a3a0159e6"
    # # options = { serverURL, secretKeyHex }
    # serverId = null
    # options = { serverURL, serverId,  secretKeyHex, publicKeyHex }
    
    # masterClient = new RPCAuthMasterClient(options)

    return
    #

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

