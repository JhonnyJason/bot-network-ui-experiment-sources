############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("observerclient")
#endregion

############################################################
#region imports
import * as sci from "./observerinterface.js"
import * as auth from "./authclientmodule.js"

#endregion

############################################################
export class Client
    constructor: (@serverURL, @secretKeyHex) ->
        o = {
            serverURL: @serverURL
            secretKeyHex: @secretKeyHex
        }
        @authClient = auth.createClient(o)


    ########################################################
    updateServerURL: (serverURL) ->
        @serverURL = serverURL
        @authClient.updateServerURL(serverURL)
        return

    updateSecretKey: (secretKeyHex) ->
        @secretKeyHex = secretKeyHex
        @authClient.updateSecretKey(secretKeyHex)
        return


    ########################################################
    getLatestOrders: (assetPairs, subscriber = "none") ->
        if typeof assetPairs == "string" then assetPairs = [assetPairs]
        return await getLatestOrders(assetPairs, subscriber, this)

    getLatestTickers: (assetPairs, subscriber = "none") ->
        if typeof assetPairs == "string" then assetPairs = [assetPairs]
        return await getLatestTickers(assetPairs, subscriber, this)

    getLatestBalances:  (assets, subscriber = "none") ->
        if typeof assets == "string" then assets = [assets]
        return await getLatestBalances(assets, subscriber, this)



############################################################
#region effectiveSCI

############################################################
getLatestOrders = (assetPairs, subscriber, client) ->
    server = client.serverURL
    authCode = await client.authClient.getAuthCode()

    requestObj = { authCode, assetPairs, subscriber }
    requestString = JSON.stringify(requestObj)

    replyP = sci.getLatestOrders(server, authCode, assetPairs, subscriber)
    authP = client.authClient.createNextAuthCode(requestString)
    [reply, ok] = await Promise.all([replyP, authP])

    if reply.error then throw new Error("getLatestorders replied with error: #{reply.error}") 
    return reply

############################################################
getLatestTickers = (assetPairs, subscriber, client) ->
    server = client.serverURL
    authCode = await client.authClient.getAuthCode()

    requestObj = { authCode, assetPairs, subscriber }
    requestString = JSON.stringify(requestObj)

    replyP = sci.getLatestTickers(server, authCode, assetPairs, subscriber)
    authP = client.authClient.createNextAuthCode(requestString)
    [reply, ok] = await Promise.all([replyP, authP])

    if reply.error then throw new Error("getLatestTickers replied with error: #{reply.error}") 
    return reply

############################################################
getLatestBalances = (assets, subscriber, client) ->
    server = client.serverURL
    authCode = await client.authClient.getAuthCode()

    requestObj = { authCode, assets, subscriber }
    requestString = JSON.stringify(requestObj)

    replyP = sci.getLatestBalances(server, authCode, assets, subscriber)
    authP = client.authClient.createNextAuthCode(requestString)
    [reply, ok] = await Promise.all([replyP, authP])

    if reply.error then throw new Error("getLatestBalances replied with error: #{reply.error}") 
    return reply


#endregion


