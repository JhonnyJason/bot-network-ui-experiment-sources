indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.content = document.getElementById("content")
    global.latestOrdersButton = document.getElementById("latest-orders-button")
    global.latestTickersButton = document.getElementById("latest-tickers-button")
    global.latestBalancesButton = document.getElementById("latest-balances-button")
    global.displayRegularOperationsResponseContainer = document.getElementById("display-regular-operations-response-container")
    global.tutorialConfigureKeyButton = document.getElementById("tutorial-configure-key-button")
    global.settingsButton = document.getElementById("settings-button")
    global.settingsoffButton = document.getElementById("settingsoff-button")
    global.deleteconfirmation = document.getElementById("deleteconfirmation")
    global.accountsettings = document.getElementById("accountsettings")
    global.idDisplay = document.getElementById("id-display")
    global.idQrButton = document.getElementById("id-qr-button")
    global.generateKeyButton = document.getElementById("generate-key-button")
    global.importKeyButton = document.getElementById("import-key-button")
    global.exportKeyButton = document.getElementById("export-key-button")
    global.deleteKeyButton = document.getElementById("delete-key-button")
    global.settingsButton = document.getElementById("settings-button")
    global.settingsoffButton = document.getElementById("settingsoff-button")
    global.phraseunlockFrame = document.getElementById("phraseunlock-frame")
    global.phraseunlockInput = document.getElementById("phraseunlock-input")
    global.unlockButton = document.getElementById("unlock-button")
    global.cancelUnlockButton = document.getElementById("cancel-unlock-button")
    global.phraseinputFrame = document.getElementById("phraseinput-frame")
    global.phraseinput = document.getElementById("phraseinput")
    global.acceptPhraseButton = document.getElementById("accept-phrase-button")
    global.cancelPhraseButton = document.getElementById("cancel-phrase-button")
    global.qrreaderBackground = document.getElementById("qrreader-background")
    global.qrreaderVideoElement = document.getElementById("qrreader-video-element")
    global.messagebox = document.getElementById("messagebox")
    global.qrdisplayBackground = document.getElementById("qrdisplay-background")
    global.qrdisplayContent = document.getElementById("qrdisplay-content")
    global.qrdisplayQr = document.getElementById("qrdisplay-qr")
    return
    
module.exports = indexdomconnect