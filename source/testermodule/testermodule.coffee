############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("testermodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as payloads from "./payloads.js"

############################################################
import { TestClient } from "./rpctestclient.js"


results = {}
payloadSize = ""
payloadLoad = ""

rpcPostClient = null

############################################################
export initialize = ->
    log "initialize"

    # ## Client Setup
    # secretKeyHex = S.load("secretKeyHex")
    # if !secretKeyHex?
    #     keyPairHex = await cryptoUtl.createKeyPairHex()
    #     S.save("secretKeyHex", keyPairHex.secretKeyHex)
    #     S.save("publicKeyHex", keyPairHex.publicKeyHex)
    #     secretKeyHex = keyPairHex.secretKeyHex

    # publicKeyHex = S.load("publicKeyHex")
    # serverURL = "https://localhost:6969/thingy-post-rpc"
    # serverId = "a8d9607f6cc919af3df3850084f63c9536efea790b3f80f514717d2a3a0159e6"
    # # options = { serverURL, secretKeyHex }
    # options = { serverURL, serverId,  secretKeyHex, publicKeyHex }
    
    # olog options

    # rpcPostClient = new TestClient(options)
    # runTests()
    return


############################################################
runNoneAuthTests = (count) ->
    resultKey = "NoneAuthx#{count} - #{payloadSize}"
    try
        before = performance.now()

        while(count--)
            response = await rpcPostClient.testNoneAuth(payloadLoad)
    
        after = performance.now()
        diff = after - before
        timespan = "#{diff}ms"
        results[resultKey] = timespan
    catch err then results[resultKey] = err.message
    return

runAnonymousTests = (count) ->
    resultKey = "Anonymousx#{count} - #{payloadSize}"
    try
        before = performance.now()

        while(count--)
            response = await rpcPostClient.testAnonymousAuth(payloadLoad)
    
        after = performance.now()
        diff = after - before
        timespan = "#{diff}ms"
        results[resultKey] = timespan
    catch err then results[resultKey] = err.message
    return

runPublicAcessTests = (count) ->
    resultKey = "PublicAccessx#{count} - #{payloadSize}"
    try
        before = performance.now()

        while(count--)
            response = await rpcPostClient.testPublicAccessAuth(payloadLoad)
    
        after = performance.now()
        diff = after - before
        timespan = "#{diff}ms"
        results[resultKey] = timespan
    catch err then results[resultKey] = err.message
    return

runSignatureTests = (count) ->
    resultKey = "Signaturex#{count} - #{payloadSize}"
    try
        before = performance.now()

        while(count--)
            response = await rpcPostClient.testSignatureAuth(payloadLoad)
    
        after = performance.now()
        diff = after - before
        timespan = "#{diff}ms"
        results[resultKey] = timespan
    catch err then results[resultKey] = err.message
    return

############################################################
runTokenSimpleTests = (count) ->
    resultKey = "TokenSimplex#{count} - #{payloadSize}"
    try
        before = performance.now()

        while(count--)
            response = await rpcPostClient.testTokenSimpleAuth(payloadLoad)
    
        after = performance.now()
        diff = after - before
        timespan = "#{diff}ms"
        results[resultKey] = timespan
    catch err then results[resultKey] = err.message
    return

############################################################
runAuthCodeSHA2Tests = (count) ->
    resultKey = "AuthCodeSHA2x#{count} - #{payloadSize}"
    try
        before = performance.now()

        while(count--)
            response = await rpcPostClient.testAuthCodeSHA2Auth(payloadLoad)
    
        after = performance.now()
        diff = after - before
        timespan = "#{diff}ms"
        results[resultKey] = timespan
    catch err then results[resultKey] = err.message
    return

############################################################
runTests = ->
    log "runTests"

    payloadSize = "small"
    payloadLoad = payloads.smallPayload

    await runNoneAuthTests(10)
    await runAnonymousTests(10)
    await runPublicAcessTests(10)
    await runSignatureTests(10)
    await runTokenSimpleTests(10)
    await runAuthCodeSHA2Tests(10)
    olog results
    return

    await runNoneAuthTests(100)
    await runAnonymousTests(100)
    await runPublicAcessTests(100)
    await runSignatureTests(100)
    await runTokenSimpleTests(100)
    await runAuthCodeSHA2Tests(100)
    
    await runNoneAuthTests(500)
    await runAnonymousTests(500)
    await runPublicAcessTests(500)
    await runSignatureTests(500)
    await runTokenSimpleTests(500)
    await runAuthCodeSHA2Tests(500)

    payloadSize = "medium"
    payloadLoad = payloads.mediumPayload

    await runNoneAuthTests(100)
    await runAnonymousTests(100)
    await runPublicAcessTests(100)
    await runSignatureTests(100)
    await runTokenSimpleTests(100)
    await runAuthCodeSHA2Tests(100)

    await runNoneAuthTests(500)
    await runAnonymousTests(500)
    await runPublicAcessTests(500)
    await runSignatureTests(500)
    await runTokenSimpleTests(500)
    await runAuthCodeSHA2Tests(500)


    payloadSize = "large"
    payloadLoad = payloads.largePayload

    await runNoneAuthTests(100)
    await runAnonymousTests(100)
    await runPublicAcessTests(100)
    await runSignatureTests(100)
    await runTokenSimpleTests(100)
    await runAuthCodeSHA2Tests(100)

    await runNoneAuthTests(500)
    await runAnonymousTests(500)
    await runPublicAcessTests(500)
    await runSignatureTests(500)
    await runTokenSimpleTests(500)
    await runAuthCodeSHA2Tests(500)

    olog results

    return