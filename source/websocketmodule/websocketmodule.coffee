############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("websocketmodule")
#endregion

############################################################
import * as S from "./statemodule.js"


############################################################
krakenObserverSocket = null

############################################################
export initialize = ->
    log "initialize"
    ## TODO handle chosen URLs
    serverURL = "wss://localhost:6969/thingy-ws-rpc"
    socketName = "krakenObserverSocket"

    # krakenObserverSocket = new ThingySocket(serverURL, socketName)
    # krakenObserverSocket.connect()
    return

############################################################
class ThingySocket
    constructor: (@serverURL, @name) ->
        @socket = null
        @connectionId = null
        @keepDisconnected = true
        
        @readinessBlock = null
        @readinessSignal = null
        @readinessReject = null
        
        @pendingReconnect = false
        @reconnectCount = 0
        @reconnectTimeoutMS  = timeoutMSForReconnectCount(@reconnectCount)

    ########################################################
    updateServerURL: (serverURL) ->
        log "#{@name}.updateServerURL"
        @serverURL = serverURL
        if @socket?
            @destroySocket()            
            @pendingReconnect = false
            @reconnectCount = 0
            @reconnectTimeoutMS = timeoutMSForReconnectCount(@reconnectCount)
            @createSocket()
        return
    
    ########################################################
    connect: ->
        log "#{@name}.connect"
        @keepDisconnected = false

        @createSocket()
        return @readinessBlock

    reconnectSocket: ->
        log "#{@name}.reconnectSocket"
        @pendingReconnect = false

        @reconnectCount++
        @reconnectTimeoutMS = timeoutMSForReconnectCount(@reconnectCount)
        @createSocket()
        return @readinessBlock

    disconnect: ->
        log "#{@name}.disconnect"
        return if @socket == null
        
        @keepDisconnected = true
        @destroySocket()
        return
    
    ########################################################
    createSocket: ->
        log "#{@name}.createSocket"
        if !@readinessBlock? then @readinessBlock = new Promise (resolve, reject) ->
            @readinessSignal = resolve
            @readinessReject = reject

        @socket = new WebSocket(@serverURL)
        @socket.onerror = @onError.bind(this)
        @socket.onclose = @onDisconnect.bind(this)
        @socket.onopen = @onConnect.bind(this)
        @socket.onmessage = @onMessage.bind(this)
        return

    destroySocket: ->
        log "#{@name}.destroySocket"

        if !@readinessBlock? then readinessReject("destroyed!")
        
        @readinessBlock = null
        @readinessSignal = null
        @readinessReject = null

        @socket.onerror = null
        @socket.onclose = null
        @socket.onopen = null
        @socket.onmessage = null
        @socket.close()
        @socket = null
        return

    ########################################################
    sendMessage: (message) ->
        log "#{@name}.sendMessage #{message}"
        return if @keepDisconnected

        log "waiting for readinessBlock..."
        await @readinessBlock
        log "sending message..."
        @socket.send(message)
        return

    ########################################################
    onError: (evnt) ->
        log "#{@name}.onError"
        olog evnt
        log evnt.reason
        return

    onDisconnect: (evnt) ->
        log "#{@name}.onDisconnect"
        return if @keepDisconnected
        return if @pendingReconnect

        log "reconnecting in: #{@reconnectTimeoutMS}ms"
        @pendingReconnect = true
        setTimeout(@reconnectSocket.bind(this), @reconnectTimeoutMS)
        return

    onConnect: (evnt) ->
        log "#{@name}.onConnect"
        @reconnectCount = 0
        @reconnectTimeoutMS = timeoutMSForReconnectCount(0)
        
        if @readinessSignal?
            @readinessSignal()
            # @readinessSignal = null
            # @readinessBlock = null
            # @readinessReject
        @sendMessage("hello!")
        log "finished onConnect..."
        return            

    onMessage: (evnt) ->
        log "#{@name}.onMessage"
        log evnt.data

        # TODO rework message processing

        # keyEnd = evnt.data.indexOf(" ")
        # if keyEnd < 0 then key = evnt.data.trim()
        # else 
        #     key = evnt.data.substring(0, keyEnd)
        #     # log typeof key
        #     # log key
        #     content = evnt.data.substring(keyEnd).trim()
        #     # log typeof content
        #     # log content

        # switch key
        #     when "alluids" then applyAllUUIDS(content)
        #     when "chat" then handleChat(content)
        #     when "sdp" then webRTC.handleSDP(content)
        #     else log "unknown key #{key}"

        return

############################################################
timeoutMSForReconnectCount = (reconnectCount) ->
    if reconnectCount > 5 then return 15000
    else return reconnectCount * 300