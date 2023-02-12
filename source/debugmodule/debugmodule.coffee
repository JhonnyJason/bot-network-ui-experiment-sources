import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = {

    # accountsettingsmodule: true
    authclient: true
    # authclientmodule: true
    # authenticationinterface: true
    # configmodule: true
    contentmodule: true
    # messageboxmodule: true
    # observerclientmodule: true
    # observerclient: true
    # observerinterface: true
    # qrdisplaymodule: true
    # qrreadermodule: true
    rpcclient: true
    rpcclientmodule: true
    # secretmanagementinterface: true
    # settingsmodule: true
    # statemodule: true
    websocketmodule: true
    
}

addModulesToDebug(modulesToDebug)