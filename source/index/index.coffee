import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
domconnect.initialize()

import { appLoaded } from "navhandler"
global.allModules = Modules

############################################################
# if navigator? and navigator.serviceWorker? then navigator.serviceWorker.register("serviceworker.js")

############################################################
appStartup = appLoaded


############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()