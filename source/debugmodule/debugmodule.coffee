import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = {

    accountsettingsmodule: true
    authclientmodule: true
    authenticationinterface: true
    configmodule: true
    contentmodule: true
    messageboxmodule: true
    qrdisplaymodule: true
    qrreadermodule: true
    secretmanagementinterface: true
    settingsmodule: true
    # statemodule: true
    validatabletimestampmodule: true
    
}

addModulesToDebug(modulesToDebug)