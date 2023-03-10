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
export class MasterClient extends RPCPostClient
    constructor: (o) ->
        super(o)

    ########################################################
    addClient: (clientPublicKey) ->
        authType = "masterSignature" 
        args = { clientPublicKey }
        func = "addClientToServe"
        return @doRPC(func, args, authType)

    removeClient: (clientPublicKey) ->
        authType = "masterSignature" 
        args = { clientPublicKey }
        func = "removeClient"
        return @doRPC(func, args, authType)

    getClients: ->
        authType = "masterSignature" 
        args = {  }
        func = "getClientsToServe"
        return @doRPC(func, args, authType)

