############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("testermodule")
#endregion

############################################################
import * as state from "./statemodule.js"

############################################################
import { TestClient } from "./rpctestclient.js"

############################################################
export initialize = ->
    log "initialize"

    ## Client Setup
    secretKeyHex = state.get("secretKeyHex")
    if !secretKeyHex? 
        keyPairHex = await cryptoUtl.createKeyPairHex()
        state.save("secretKeyHex", keyPairHex.secretKeyHex)
        state.save("publicKeyHex", keyPairHex.publicKeyHex)
        secretKeyHex = keyPairHex.secretKeyHex
    publicKeyHex = state.get("publicKeyHex")
    serverURL = "https://localhost:6969/thingy-post-rpc"
    serverId = "194202ec1cea1cad68af7034803ca53e1687a5170e3b29bdf6fae432003c4927"
    # options = { serverURL, secretKeyHex }
    options = { serverURL, serverId,  secretKeyHex, publicKeyHex }
    
    rpcPostClient = new TestClient(options)
    runTests(rpcPostClient)
    return


runTests = (client) ->
    log "runTests"
    response = await client.testSignatureAuth("Hello World! Nr.1")
    olog response
    return