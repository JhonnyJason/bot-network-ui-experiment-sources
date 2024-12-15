############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("navtriggers")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as S from "./statemodule.js"

############################################################
## Navigation Action Triggers

############################################################
export mainView = ->
    return nav.toRoot(true)

export addExchange = ->
    return nav.toBaseAt("add-exchange", null, 1)

export controlExchange = (exchangeIndex) ->
    return nav.toBaseAt("exchange-overview", {exchangeIndex}, 1)

############################################################
export reset = ->
    return nav.toRoot(true)

############################################################
export back = ->
    return nav.back(1)
    
############################################################
export settingsOn = ->
    return nav.toBase("settings")

############################################################
export settingsAccount = ->
    return nav.toBase("settings-account")

export keyGeneration = ->
    return nav.toBase("settings-account-keygeneration")

export phraseProtect = ->
    return nav.toMod("phraseinput")

export qrProtect = ->
    return nav.toMod("qrinput")

export keyImport = ->
    return nav.toBase("settings-account-keyimport")

export keyExport = ->
    return nav.toBase("settings-account-keyexport")


############################################################
export unlockWithQR = ->
    return nav.toMod("qrunlock")

export unlockWithPhrase = ->
    return nav.toMod("phraseunlock")


############################################################
export settingsBackend = ->
    return nav.toBase("settings-backend")

############################################################
export deleteKey =  ->
    return nav.toMod("deleteconfirmation")

