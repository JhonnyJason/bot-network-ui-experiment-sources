############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("rpcpostclient")
#endregion

############################################################
#region imports
# import * as secUtl from "secret-manager-crypto-utils"
# import * as tbut from "thingy-byte-utils"
# import * as sess from "thingy-session-utils"
# import * as validatableStamp from "validatabletimestamp"

import { RPCPostClient } from "./rpcpostclient.js"

#endregion

############################################################
export class TestClient extends RPCPostClient
    constructor: (o) ->
        super(o)

    ########################################################
    testSignatureAuth: (message) ->
        authType = "signature" 
        args = { message }
        func = "testSignatureAuth"
        return @doRPC(func, args, authType)

    testMasterSignatureAuth: (message) ->
        authType = "masterSignature" 
        args = { message }
        func = "testMasterSignatureAuth"
        return @doRPC(func, args, authType)

    testClientSignatureAuth: (message) ->
        authType = "clientSignature" 
        args = { message }
        func = "testClientSignatureAuth"
        return @doRPC(func, args, authType)


    ########################################################
    testAnonymousAuth: (message) ->
        authType = "anonymous" 
        args = { message }
        func = "testAnonymousAuth"
        return @doRPC(func, args, authType)

    testPublicAccessAuth: (message) ->
        authType = "publicAccess" 
        args = { message }
        func = "testPublicAccessAuth"
        return @doRPC(func, args, authType)


    ########################################################
    testTokenSimpleAuth: (message) ->
        authType = "tokenSimple" 
        args = { message }
        func = "testTokenSimpleAuth"
        return @doRPC(func, args, authType)

    testTokenUniqueAuth: (message) ->
        authType = "tokenUnique" 
        args = { message }
        func = "testTokenUniqueAuth"
        return @doRPC(func, args, authType)
    

    ########################################################
    testAuthCodeLightAuth: (message) ->
        authType = "tokenUnique" 
        args = { message }
        func = "testAuthCodeLightAuth"
        return @doRPC(func, args, authType)

    testAuthCodeSHA2Auth: (message) ->
        authType = "tokenUnique" 
        args = { message }
        func = "testAuthCodeSHA2Auth"
        return @doRPC(func, args, authType)
