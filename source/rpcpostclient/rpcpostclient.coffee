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
# import * as sess from "thingy-session-utils"

import { NetworkError, ResponseAuthError, RPCError } from "./rpcerrors.js"

#endregion

############################################################
export class RPCPostClient
    constructor: (o) ->
        @serverURL = o.serverURL
        @serverId = o.serverId
        @secretKeyHex = o.secretKeyHex
        @publicKeyHex = o.publicKeyHex
        @requestId = 0
        @sessionInfo = {}

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
            when "anonymous" then return  doAnonymousRPC(func, args, this)
            when "public" then return doPublicRPC(func, args, this)
            when "tokenSimple" then return doTokenSimpleRPC(func, args, this)
            when "tokenUnique" then return doTokenUniqueRPC(func, args, this)
            when "authCodeLight" then return doAuthCodeLightRPC(func, args, this)
            when "authCodeSHA2" then return doAuthCodeSHA2RPC(func, args, this)
            when "signature", "clientSignature", "masterSignature"
                return doSignatureRPC(func, args, authType, this)
            else throw new Error("doRPC: Unknown authType! '#{authType}'")
        return

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
        if !response.ok then throw new Error("Response not ok - status: #{response.status}! body: #{await response.text()}")
        return await response.json()
    catch err then throw new NetworkError(err.message)



########################################################
incRequestId = (c) ->
    c.requestId = ++c.requestId % 10000000
    return



########################################################
doAnonymousRPC = (func, args, c) ->
    return

doPublicRPC = (func, args, c) ->
    return

doTokenSimpleRPC = (func, args, c) ->
    return

doTokenUniqueRPC  = (func, args, c) ->
    return

doAuthCodeLightRPC = (func, args, c) ->
    return

doAuthCodeSHA2RPC = (func, args, c) ->
    return

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
    log requestString

    response = await postRPCString(c.serverURL, requestString)
    olog response
    await authenticateServiceSignature(response, requestId, c.serverId)
    
    if response.error then throw new RPCError(response.error)

    return response.result 

############################################################
authenticateServiceSignature = (response, ourRequestId, ourServerId) ->
    try
        { signature, timestamp, requestId, serverId } = response.auth
        
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
