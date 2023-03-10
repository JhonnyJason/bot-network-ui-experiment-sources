############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("rpcpostclient")
#endregion

############################################################
#region imports
import * as secUtl from "secret-manager-crypto-utils"
import * as validatableStamp from "validatabletimestamp"
# import * as tbut from "thingy-byte-utils"
import * as sess from "thingy-session-utils"

import {
    NOT_AUTHORIZED, NetworkError, ResponseAuthError, RPCError 
} from "./rpcerrors.js"

#endregion

############################################################
TOKEN_SIMPLE = 0
TOKEN_UNIQUE = 1
AUTHCODE_LIGHT = 2
AUTHCODE_SHA2 = 3

############################################################
export class RPCPostClient
    constructor: (o) ->
        @serverURL = o.serverURL
        @serverId = o.serverId
        @serverContext = "thingy-rpc-post-connection"
        @secretKeyHex = o.secretKeyHex
        @publicKeyHex = o.publicKeyHex
        @name = "rpc-client"+randomPostfix()
        @allowImplicitSessions = o.allowImplicitSessions
        @requestId = 0
        @sessions = new Array(4)
        @anonymousToken = null
        @publicToken = null
        if o.anonymousToken? then @anonymousToken = o.anonymousToken
        if o.publicToken? then @publicToken = o.publicToken
        if o.name? then @name = o.name
        if o.serverContext? then @serverContext = o.serverContext

    ########################################################
    updateServer: (serverURL, serverId) ->
        @serverURL = serverURL
        @serverId = serverId
        @requestId = 0
        @sessionInfo = {}
        return

    updateKeys: (secretKeyHex, publicKeyHex) ->
        @secretKeyHex = secretKeyHex
        @publicKeyHex = publicKeyHex
        @requestId = 0
        @sessionInfo = {}
        return

    ########################################################
    getServerURL: -> @serverURL
    getServerId: ->
        if !@serverId? then @serverId = await getValidatedNodeId(this)
        return @serverId

    getSecretKey: -> @secretKeyHex
    getPublicKey: ->
        if !@publicKeyHex? then @publicKeyHex = await secUtl.createPublicKeyHex(@secretKeyHex)
        return @publicKeyHex

    ########################################################
    doRPC: (func, args, authType) ->
        switch authType
            when "none" then return doNoAuthRPC(func, args, this)
            when "anonymous" then return  doAnonymousRPC(func, args, this)
            when "publicAccess" then return doPublicAccessRPC(func, args, this)
            when "tokenSimple" then return doTokenSimpleRPC(func, args, this)
            when "tokenUnique" then return doTokenUniqueRPC(func, args, this)
            when "authCodeLight" then return doAuthCodeLightRPC(func, args, this)
            when "authCodeSHA2" then return doAuthCodeSHA2RPC(func, args, this)
            when "signature", "clientSignature", "masterSignature"
                return doSignatureRPC(func, args, authType, this)
            else throw new Error("doRPC: Unknown authType! '#{authType}'")
        return
    

########################################################
#region internal functions

########################################################
randomPostfix = ->
    rand = Math.random()
    return Math.round(rand * 1000)

########################################################
postRPCString = (url, requestString) ->
    options =
        method: 'POST'
        credentials: 'omit'
        body: requestString
        headers:
            'Content-Type': 'application/json'

    try
        response = await fetch(url, options)
        return await response.json()
    catch err
        baseMsg = "Error! RPC could not receive a JSON response!"
        
        try 
            bodyText = "Body:  #{await response.text()}"
            statusText = "HTTP-Status: #{response.status}"
        catch err2
            details = "No response could be retrieved! details: #{err.message}"
            errorMsg = "#{baseMsg} #{details}" 
            throw new NetworkError(errorMsg)

        details = "#{statusText} #{bodyText}"
        errorMsg = "#{baseMsg} #{details}"
        throw new NetworkError(errorMsg)
    return

########################################################
incRequestId = (c) ->
    c.requestId = ++c.requestId % 10000000
    return

########################################################
#region RPC execution functions

########################################################
doSignatureRPC = (func, args, type, c) ->
    incRequestId(c)

    clientId = await c.getPublicKey()
    requestId = c.requestId
    timestamp = validatableStamp.create()
    signature = ""

    auth = { type, clientId, requestId, timestamp, signature }
    rpcRequest = { auth, func, args }

    serverId = await c.getServerId()
    requestString = JSON.stringify(rpcRequest)
    sigHex = await secUtl.createSignature(requestString, c.secretKeyHex)
    requestString = requestString.replace('"signature":""', '"signature":"'+sigHex+'"')
    # log requestString

    response = await postRPCString(c.serverURL, requestString)
    # olog { response }

    # in case of an error
    if response.error then throw new RPCError(func, response.error)

    await authenticateServiceSignature(response, requestId, serverId)
    
    return response.result 

########################################################
#region public RPCs
doNoAuthRPC = (func, args, c) ->
    auth = null
    requestString = JSON.stringify({ auth, func, args })
    serverId = c.serverId

    response = await postRPCString(c.serverURL, requestString)
    # olog response
    
    if response.error then throw new RPCError(response.error)

    return response.result 

doAnonymousRPC = (func, args, c) ->
    incRequestId(c)

    type = "anonymous"
    requestId = c.requestId
    timestamp = validatableStamp.create()
    requestToken = c.anonymousToken

    auth = { type, requestId, timestamp, requestToken }
    
    requestString = JSON.stringify({ auth, func, args })
    serverId = c.serverId

    response = await postRPCString(c.serverURL, requestString)
    # olog response
    
    if response.error then throw new RPCError(response.error)

    return response.result 

doPublicAccessRPC = (func, args, c) ->
    incRequestId(c)

    type = "publicAccess"
    requestId = c.requestId
    clientId = await c.getPublicKey()
    timestamp = validatableStamp.create()
    requestToken = c.publicToken
    auth = { type, clientId, requestId, timestamp, requestToken }

    # olog auth

    requestString = JSON.stringify({ auth, func, args })
    serverId = c.serverId

    response = await postRPCString(c.serverURL, requestString)
    # olog response

    authenticateServiceStatement(response, requestId, serverId)

    if response.error then throw new RPCError(response.error)
    return response.result 

#endregion

########################################################
#region session RPCs
doTokenSimpleRPC = (func, args, c) ->
    await establishSimpleTokenSession(c)    
    incRequestId(c)

    type = "tokenSimple"
    clientId = await c.getPublicKey()
    requestId = c.requestId
    name = c.name
    timestamp = validatableStamp.create()
    requestToken = c.sessions[TOKEN_SIMPLE].token

    auth = { type, clientId, name, requestId, timestamp, requestToken }
    rpcRequest = { auth, func, args }
    requestString = JSON.stringify(rpcRequest)

    serverId = await c.getServerId()
    response = await postRPCString(c.serverURL, requestString)
    # olog { response }

    # in case of an error
    if response.error
        corruptSession = response.error.code? and response.error.code == NOT_AUTHORIZED
        if corruptSession then c.sessions[TOKEN_SIMPLE] = null
        throw new RPCError(func, response.error)

    await authenticateServiceStatement(response, requestId, serverId)
    return response.result 

doTokenUniqueRPC  = (func, args, c) ->
    throw new Error("doTokenUniqueRPC: Not Implemented yet!")
    # await establishUniqueTokenSession(c)
    # incRequestId(c)

    return

doAuthCodeLightRPC = (func, args, c) ->
    throw new Error("doAuthCodeLightRPC: Not Implemented yet!")
    # await establishAuthCodeLightSession(c)    
    # incRequestId(c)

    return

doAuthCodeSHA2RPC = (func, args, c) ->
    await establishSHA2AuthCodeSession(c)    
    incRequestId(c)

    session = c.sessions[AUTHCODE_SHA2]

    type = "authCodeSHA2"
    clientId = await c.getPublicKey()
    requestId = c.requestId
    name = c.name
    timestamp = validatableStamp.create()
    requestAuthCode = ""

    auth = { type, clientId, name, requestId, timestamp, requestAuthCode }
    rpcRequest = { auth, func, args }

    serverId = await c.getServerId()
    requestString = JSON.stringify(rpcRequest)
    authCode = await sess.createAuthCode(session.seedHex, requestString)
    requestString = requestString.replace('"requestAuthCode":""', '"requestAuthCode":"'+authCode+'"')
    # log requestString

    response = await postRPCString(c.serverURL, requestString)
    # olog { response }

    # in case of an error
    if response.error
        corruptSession = response.error.code? and response.error.code == NOT_AUTHORIZED
        if corruptSession then c.sessions[AUTHCODE_SHA2] = null
        throw new RPCError(func, response.error)

    await authenticateServiceAuthCodeSHA2(response, requestId, serverId, c)
    
    return response.result 

#endregion

#endregion

############################################################
#region session establishment
startSessionExplicitly = (type, c) ->
    incRequestId(c)

    name = c.name
    args = { type, name }
    
    func = "startSession"
    authType = "clientSignature"
    try return await c.doRPC(func, args, authType)
    catch err then throw new Error("Explicit Start failed: #{err.message}")
    return


establishSimpleTokenSession = (c) ->
    if c.sessions[TOKEN_SIMPLE]? and c.sessions[TOKEN_SIMPLE].token? then return
    try
        session = {}
        if c.allowImplicitSessions
            session.token = await generateImplicitSimpleToken(c)
        else
            session.token = await getExplicitSimpleToken(c)
        c.sessions[TOKEN_SIMPLE] = session
    catch err
        message = "Could not establish a simple Token session! Details: #{err.message}"
        throw new Error(message)
    return

generateImplicitSimpleToken = (c) ->
    return "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"

generateImplicitAuthCodeSeed = (c) ->
    return "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"

generateExplicitAuthCodeSeed = (timestamp, c) ->
    serverContext = c.serverContext
    specificContext = c.name
    context = "#{specificContext}:#{serverContext}_#{timestamp}"
    return await secUtl.createSharedSecretHashHex(c.secretKeyHex, c.serverId, context)


getExplicitSimpleToken = (c) ->
    return startSessionExplicitly("tokenSimple", c)


establishSHA2AuthCodeSession = (c) ->
    if c.sessions[AUTHCODE_SHA2]? and c.sessions[AUTHCODE_SHA2].seedHex? then return
    try
        session = {}
        if c.allowImplicitSessions
            session.seedHex = await generateImplicitAuthCodeSeed(c)
        else
            timestamp = await startSessionExplicitly("authCodeSHA2", c)
            session.seedHex = await generateExplicitAuthCodeSeed(timestamp, c)
        c.sessions[AUTHCODE_SHA2] = session
    catch err
        message = "Could not establish a simple Token session! Details: #{err.message}"
        throw new Error(message)
    return


#endregion

############################################################
#region response Authentication
authenticateServiceSignature = (response, ourRequestId, ourServerId) ->
    try
        signature = response.auth.signature
        timestamp = response.auth.timestamp
        requestId = response.auth.requestId
        serverId = response.auth.serverId
        
        if !signature? then throw new Error("No Signature!")
        if !timestamp? then throw new Error("No Timestamp!")
        if !requestId? then throw new Error("No RequestId!")
        if !serverId? then throw new Error("No ServerId!")
        
        if requestId != ourRequestId then throw new Error("RequestId Mismatch!")
        if serverId != ourServerId then throw new Error("ServerId Mismatch!")
        
        validatableStamp.assertValidity(timestamp)
        
        response.auth.signature = ""
        responseString = JSON.stringify(response)
        verified = await secUtl.verify(signature, serverId, responseString)
        if !verified then throw new Error("Invalid Signature!")

    catch err then throw new ResponseAuthError(err.message)
    return

authenticateServiceStatement = (response, ourRequestId, ourServerId) ->
    try
        timestamp = response.auth.timestamp
        requestId = response.auth.requestId
        serverId = response.auth.serverId
        
        if !timestamp? then throw new Error("No Timestamp!")
        if !requestId? then throw new Error("No RequestId!")
        if !serverId? then throw new Error("No ServerId!")
        
        if requestId != ourRequestId then throw new Error("RequestId Mismatch!")
        if serverId != ourServerId then throw new Error("ServerId Mismatch!")
        
        validatableStamp.assertValidity(timestamp)
        
    catch err then throw new ResponseAuthError(err.message)
    return

authenticateServiceAuthCodeSHA2 = (response, ourRequestId, ourServerId, c) ->
    try
        responseAuthCode = response.auth.responseAuthCode
        timestamp = response.auth.timestamp
        requestId = response.auth.requestId
        serverId = response.auth.serverId
        
        if !responseAuthCode? then throw new Error("No ResponseAuthCode!")
        if !timestamp? then throw new Error("No Timestamp!")
        if !requestId? then throw new Error("No RequestId!")
        if !serverId? then throw new Error("No ServerId!")
        
        if requestId != ourRequestId then throw new Error("RequestId Mismatch!")
        if serverId != ourServerId then throw new Error("ServerId Mismatch!")
        
        validatableStamp.assertValidity(timestamp)
        
        session = c.sessions[AUTHCODE_SHA2]
        if !session? or !session.seedHex? then throw new Error("Local session object has become invalid!")
        response.auth.responseAuthCode = ""
        responseString = JSON.stringify(response)
        # log responseString
        authCode = await sess.createAuthCode(session.seedHex, responseString)
        # olog { authCode, responseAuthCode }
        
        if authCode != responseAuthCode then throw new Error("AuthCodes did not Match!")
    catch err then throw new ResponseAuthError("authenticateServiceAuthCodeSHA2: #{err.message}")
    return

authenticateServiceAuthCodeLight = (response, ourRequestId, ourServerId, c) ->
    try
        responseAuthCode = response.auth.responseAuthCode
        timestamp = response.auth.timestamp
        requestId = response.auth.requestId
        serverId = response.auth.serverId
        
        if !responseAuthCode? then throw new Error("No ResponseAuthCode!")
        if !timestamp? then throw new Error("No Timestamp!")
        if !requestId? then throw new Error("No RequestId!")
        if !serverId? then throw new Error("No ServerId!")
        
        if requestId != ourRequestId then throw new Error("RequestId Mismatch!")
        if serverId != ourServerId then throw new Error("ServerId Mismatch!")
        
        validatableStamp.assertValidity(timestamp)
        
        session = c.sessions[AUTHCODE_Light]
        if !session? or !session.seedHex? then throw new Error("Local session object has become invalid!")
        response.auth.requestAuthCode = ""
        responseString = JSON.stringify(response)

        throw new Error("Not implemented yet!")
        # authCode = await sess.createAuthCodeLight(session.seedHex, requestString)
        if authCode != responseAuthCode then throw new Error("AuthCodes did not Match!")
    catch err then throw new ResponseAuthError("authenticateServiceAuthCodeLight: #{err.message}")
    return


#endregion

#endregion






# ############################################################
# #region internalFunctions

# ############################################################
# #region misc Helpers

# ############################################################
# directSessionSetup = (client) ->
#     log "directSessionSetup"
#     secretKey = client.secretKeyHex

#     publicKey = await client.getPublicKey()
#     server = client.serverURL
#     timestamp = validatableStamp.create()
    
#     requestId = client.requestId
#     client.incRequestId()
    
#     auth = {
#         type: "signature"
#         clientId: publicKey
#         requestId: requestId
#         timestamp: timestamp
#         signature: ""
#     }
#     func = "startSession"
#     args = {
#         cliendId: publicKey
#     }
#     rpcRequest = {auth, func, args}

#     requestString = JSON.stringify(rpcRequest)
#     sigHex = await secUtl.createSignature(requestString, secretKey)
#     requestString = requestString.replace('"signature":""', '"signature":"'+sigHex+'"')
#     log requestString

#     return

#     # request = { publicKey, timestamp, requestId, signature }
#     # request = JSON.stringify(request)

#     # log "/startSession + generateNextAuthCode"    
#     # replyP = sci.startSession(sciURL, publicKey, timestamp, requestId, signature)
#     # authP = client.createNextAuthCode(request)
#     # [reply, ok] = await Promise.all([replyP, authP])
#     # # try await authP
#     # # catch err then throw new Error("creating authCode threw error: #{err.message}")

#     # if reply.error then throw new Error("startSession replied with error: #{reply.error}")
#     # return

# ############################################################
# implicitSessionSetup = (client) ->
#     log "implicitSessionSetup - TODO"
#     ## TODO
#     return

# ############################################################
# getValidatedNodeId = (client) ->
#     log "getValidatedNodeId"
#     try 
#         response = await getNodeId(client)
#         # {
#         #     "serverNodeId": "...",
#         #     "timestamp": "...",
#         #     "signature": "..."
#         # }
#         # idHex = response.serverNodeId
#         # timestamp = response.timestamp
#         # sigHex = response.signature
        
#         # delete response.signature
#         # content = JSON.stringify(response)
#         # console.log(content)

#         # await authenticateResponse(content, sigHex, idHex, timestamp)
#     catch err then throw new Error("getValidatedNodeId - #{err.message}")
#     return idHex
    
# ############################################################
# authenticateResponse = (content, sigHex, idHex, timestamp) ->
#     try
#         if !timestamp then throw new Error("No Timestamp!") 
#         if !sigHex then throw new Error("No Signature!")
#         if !idHex then throw new Error("No Public key!")

#         validatableStamp.assertValidity(timestamp) 
#         verified = await secUtl.verify(sigHex, idHex, content)

#         if !verified then throw new Error("Invalid Signature!")
        
#     catch err then throw new Error("Error on authenticateResponse! " + err)
#     return

# assertValidResponseIds = (auth, serverId, requestId) ->
#     if !auth.serverId? then throw new ResponseAuthError("No ServerId!")
#     if !auth.requestId? then throew new ResponseAuthError("No RequestId!")
#     if auth.serverId != serverId then throw new ResponseAuthError("Wrong ServerId!")
#     if auth.requestId != requestId then throw new ResponseAuthError("Wrong RequestId")
#     return

# assertValidResponseAuthCode = (responseString, auth, seedHex, serverId, requestId) ->
#     assertValidResponseIds(auth, serverId, requestId)
#     validatableStamp.assertValidity(auth.timestamp)
#     responseString = responseString.replace(auth.signature, "")
#     verified = await secUtl.verify(auth.signature, serverId, responseString)
#     if !verified then throw new ResponseAuthError("Invalid Signature!")
#     return
    
# assertValidResponseSignature = (auth, serverId, requestId) ->

# #endregion


# ############################################################
# #region cryptoHelpers
# decrypt = (content, secretKey) ->
#     content = await secUtl.asymmetricDecrypt(content, secretKey)
#     content = secUtl.removeSalt(content)
#     try content = JSON.parse(content) 
#     catch err then return content # was no stringified Object


#     if content.encryptedContent? || content.encryptedContentHex? 
#         content = await secUtl.asymmetricDecrypt(content, secretKey)
#         content = secUtl.removeSalt(content)
#         try content = JSON.parse(content)
#         catch err then return content # was no stringified Object

#     return content

# ############################################################
# encrypt = (content, publicKey) ->
#     if typeof content == "object" then content = JSON.stringify(content)
#     salt = secUtl.createRandomLengthSalt()    
#     content = salt + content

#     content = await secUtl.asymmetricEncrypt(content, publicKey)
#     return JSON.stringify(content)

# ############################################################
# createSignature = (payload, route, secretKeyHex) ->
#     content = route+JSON.stringify(payload)
#     return 

# #endregion

# ############################################################
# #region effectiveSCI
# getNodeId = (client) ->
#     secretKey = client.secretKeyHex
#     publicKey = await client.getPublicKey()
#     server = client.serverURL
#     timestamp = validatableStamp.create()

#     requestId = client.requestId
#     client.incRequestId()

#     auth = {
#         type: "public"
#         clientId: publicKey
#         requestId: requestId
#         timestamp: timestamp
#     }
#     func = "getNodeId"
#     args = { }
#     rpcRequest = {auth, func, args}

#     requestString = JSON.stringify(rpcRequest)

#     log requestString

#     response = await postRPCString(server, requestString)
#     olog response

#     if response.error then throw new Error("getClientsToServe replied with error: #{response.error.message}")

#     return response.result 

#     # log "getNodeId"
#     # olog payload

#     # signature = await createSignature(payload, route, secretKey)    
#     # reply = await sci.getNodeId(sciURL, publicKey, timestamp, requestId, signature)
#     # if reply.error? then throw new Error("getNodeId replied with error: "+reply.error)
#     # return reply



# ############################################################
# addClientToServe = (clientPublicKey, client) ->
#     secretKey = client.secretKeyHex

#     publicKey = await client.getPublicKey()
#     server = client.serverURL
#     timestamp = validatableStamp.create()
    
#     requestId = client.requestId
#     client.incRequestId()

#     auth = {
#         type: "masterSignature"
#         clientId: publicKey
#         requestId: requestId
#         timestamp: timestamp
#         signature: ""
#     }
#     func = "addClientToServe"
#     args = { clientPublicKey }
#     rpcRequest = {auth, func, args}

#     requestString = JSON.stringify(rpcRequest)
#     sigHex = await secUtl.createSignature(requestString, secretKey)
#     requestString = requestString.replace('"signature":""', '"signature":"'+sigHex+'"')
#     log requestString

#     response = await postRPCString(server, requestString)
#     olog response

#     if response.error then throw new Error("addClientToServe replied with error: #{response.error.message}")

#     return response.result 


#     # payload = {clientPublicKey, timestamp, requestId}
#     # route = "/addClientToServe"

#     # signature = await createSignature(payload, route, secretKey)    
#     # reply = await sci.addClientToServe(sciURL, clientPublicKey, timestamp, requestId, signature)

#     # if reply.error then throw new Error("addClientToServe replied with error: #{reply.error}")
#     # return reply


# ############################################################
# removeClientToServe = (clientPublicKey, client) ->
#     secretKey = client.secretKeyHex
#     server = client.serverURL
    
#     publicKey = await client.getPublicKey()
#     timestamp = validatableStamp.create()
    
#     requestId = client.requestId
#     client.incRequestId()

#     auth = {
#         type: "masterSignature"
#         clientId: publicKey
#         requestId: requestId
#         timestamp: timestamp
#         signature: ""
#     }
#     func = "removeClientToServe"
#     args = { clientPublicKey }
#     rpcRequest = {auth, func, args}

#     requestString = JSON.stringify(rpcRequest)
#     sigHex = await secUtl.createSignature(requestString, secretKey)
#     requestString = requestString.replace('"signature":""', '"signature":"'+sigHex+'"')
#     log requestString

#     response = await postRPCString(server, requestString)
#     olog response

#     if response.error then throw new Error("removeClientToServe replied with error: #{response.error.message}")

#     return response.result 

#     # payload = {clientPublicKey, timestamp, requestId}
#     # route = "/removeClientToServe"

#     # signature = await createSignature(payload, route, secretKey)    
#     # reply = await sci.removeClientToServe(sciURL, clientPublicKey, timestamp, requestId, signature)

#     # if reply.error then throw new Error("removeClientToServe replied with error: #{reply.error}")
#     # return reply

# ############################################################
# getClientsToServe = (client) ->
#     secretKey = client.secretKeyHex
#     server = client.serverURL

#     publicKey = await client.getPublicKey()
#     timestamp = validatableStamp.create()
    
#     requestId = client.requestId
#     client.incRequestId()

#     auth = {
#         type: "masterSignature"
#         clientId: publicKey
#         requestId: requestId
#         timestamp: timestamp
#         signature: ""
#     }
#     func = "getClientsToServe"
#     args = { }
#     rpcRequest = {auth, func, args}

#     requestString = JSON.stringify(rpcRequest)
#     sigHex = await secUtl.createSignature(requestString, secretKey)
#     requestString = requestString.replace('"signature":""', '"signature":"'+sigHex+'"')
#     log requestString

#     response = await postRPCString(server, requestString)
#     olog response

#     if response.error then throw new Error("getClientsToServe replied with error: #{response.error.message}")

#     return response.result 

#     # payload = {timestamp, requestId}
#     # route = "/getClientsToServe"

#     # signature = await createSignature(payload, route, secretKey)    
#     # reply = await sci.getClientsToServe(sciURL, timestamp, requestId, signature)

#     # if reply.error then throw new Error("getClientsToServe replied with error: #{reply.error}")
#     # return reply

# #endregion

# #endregion

    # getAuthCode: ->
    #     log "Client.getAuthCode"
    #     log "authCode: "+@nextAuthCode
    #     if @nextAuthCode? then return @nextAuthCode

    #     # await indirectSessionSetup(this)
    #     # await implicitSessionSetup(this)
    #     await directSessionSetup(this)
        
    #     return @nextAuthCode
    
    # createNextAuthCode: (request) ->
    #     log "Client.createNextAuthCode"
    #     if !@seedHex? then await @generateSeedEntropy()
    #     @nextAuthCode = await sess.createAuthCode(@seedHex, request)
    #     authCode = @nextAuthCode
    #     # request = request
    #     seedHex = @seedHex
 
    #     # olog {request}
    #     # olog {seedHex}
    #     # log "result:"
    #     # olog { authCode }
    #     return true

    # onError: (error) ->
    #     log "noticeError"
    #     @nextAuthCode = null
    
    #     # log error
    #     # if error.indexOf("authentication: Invalid authCode!") > -1
    #     #     @nextAuthCode = null

    #     ## TODO check if we have other errors to handle
    #     throw error
        
    # ########################################################
    # generateSeedEntropy: ->
    #     serverId = await @getServerId()
    #     context = "lenny test context"+validatableStamp.create()
    #     @seedHex = await secUtl.createSharedSecretHashHex(@secretKeyHex, serverId, context)
    #     return 
