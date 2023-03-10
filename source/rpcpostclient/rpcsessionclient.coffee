############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("rpcmasterclient")
#endregion

############################################################
#region imports
import { RPCPostClient } from "./rpcpostclient.js"

#endregion

############################################################
export class SessionClient extends RPCPostClient
    constructor: (o) ->
        super(o)

    ########################################################
    startSession: ->
        type = "tokenSimple"
        sessionName = "session X"
        args = { type, sessionName }
        
        func = "startSession"
        authType = "clientSignature" 
        return @doRPC(func, args, authType)

    stopSession: ->
        authType = "clientSignature" 
        args = {  }
        func = "stopSession"
        return @doRPC(func, args, authType)


