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

    try    
        response = await client.testSignatureAuth("testSignatureAuth")
        olog response
    catch err then log err

    try    
        response = await client.testPublicAccessAuth("testPublicAccessAuth")
        olog response
    catch err then log err

    try
        response = await client.testAnonymousAuth("testAnonymousAuth")
        olog response
    catch err then log err

    try
        response = await client.testMasterSignatureAuth("testMasterSignatureAuth")
        olog response
    catch err then log err

    try
        response = await client.testClientSignatureAuth("testClientSignatureAuth")
        olog response
    catch err then log err

    try
        response = await client.testTokenSimpleAuth("testTokenSimpleAuth 0")
        olog response
    catch err then log err

    try
        response = await client.testTokenSimpleAuth("testTokenSimpleAuth 1")
        olog response
    catch err then log err

    try
        response = await client.testTokenSimpleAuth("testTokenSimpleAuth 2")
        olog response
    catch err then log err

    try
        response = await client.testTokenSimpleAuth("testTokenSimpleAuth 3")
        olog response
    catch err then log err

    try
        response = await client.testTokenSimpleAuth("testTokenSimpleAuth 4")
        olog response
    catch err then log err

    return