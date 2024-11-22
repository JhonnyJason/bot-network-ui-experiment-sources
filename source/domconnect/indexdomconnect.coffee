indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.content = document.getElementById("content")
    global.latestOrdersButton = document.getElementById("latest-orders-button")
    global.latestTickersButton = document.getElementById("latest-tickers-button")
    global.latestBalancesButton = document.getElementById("latest-balances-button")
    global.displayRegularOperationsResponseContainer = document.getElementById("display-regular-operations-response-container")
    global.settingsButton = document.getElementById("settings-button")
    global.settingsoffButton = document.getElementById("settingsoff-button")
    global.secretmanagerOptions = document.getElementById("secretmanager-options")
    global.accountsettings = document.getElementById("accountsettings")
    global.idDisplay = document.getElementById("id-display")
    global.idQrButton = document.getElementById("id-qr-button")
    global.addKeyButton = document.getElementById("add-key-button")
    global.deleteKeyButton = document.getElementById("delete-key-button")
    global.importKeyInput = document.getElementById("import-key-input")
    global.acceptKeyButton = document.getElementById("accept-key-button")
    global.qrScanImport = document.getElementById("qr-scan-import")
    global.floatingImport = document.getElementById("floating-import")
    global.signatureImport = document.getElementById("signature-import")
    global.copyExport = document.getElementById("copy-export")
    global.qrExport = document.getElementById("qr-export")
    global.floatingExport = document.getElementById("floating-export")
    global.signatureExport = document.getElementById("signature-export")
    global.settingsButton = document.getElementById("settings-button")
    global.settingsoffButton = document.getElementById("settingsoff-button")
    global.qrreaderBackground = document.getElementById("qrreader-background")
    global.qrreaderVideoElement = document.getElementById("qrreader-video-element")
    global.messagebox = document.getElementById("messagebox")
    global.qrdisplayBackground = document.getElementById("qrdisplay-background")
    global.qrdisplayContent = document.getElementById("qrdisplay-content")
    global.qrdisplayQr = document.getElementById("qrdisplay-qr")
    return
    
module.exports = indexdomconnect