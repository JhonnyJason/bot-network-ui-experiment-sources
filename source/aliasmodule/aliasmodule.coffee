############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("aliasmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as crypto from "./localkeymodule.js"

############################################################
storageId = ""
aliasToId = {}
idsToAlias = {}

############################################################
export initialize = ->
    log "initialize"
    return

############################################################
saveAliases = ->
    log "saveAliases"
    encrypted = await crypto.encrypt(JSON.stringify(aliasToId))
    S.save(storageId, encrypted, true)
    return

############################################################
export loadForStorageId = (rawStorageId) ->
    log "loadForStorageId"
    storageId = "#{rawStorageId}_aliases"
    log storageId
    encrypted = S.load(storageId)

    olog {
        encrypted
    }

    if encrypted? and encrypted.referencePointHex?
        aliasToId = JSON.parse(await crypto.decrypt(encrypted))
        olog {
            aliasToId
        }
        # create reverse Map
        for alias, id of aliasToId
            idsToAlias[id] = alias
        olog {
            idsToAlias
        }
        return

    aliasToId = {}
    idsToAlias = {}
    return

############################################################
export getAliasForId = (id) -> return idsToAlias[id]
export getIdForAlias = (alias) -> return aliasToId[alias]

############################################################
export setAliasForId = (alias, id) ->
    log "setAliasForId"
    if aliasToId[alias] == id then return #no change
    if aliasToId[alias]? then throw new Error("Alias is already used!")

    # unset
    oldAlias = idsToAlias[id]
    if aliasToId[oldAlias] == id then delete aliasToId[oldAlias]

    # set
    aliasToId[alias] = id
    idsToAlias[id] = alias

    saveAliases()
    return


