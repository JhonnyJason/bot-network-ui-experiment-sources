############################################################
export appVersion = "0.0.1"

############################################################
# Secret Manager
export secretManagerOptions = [
    "https://secrets.dotv.ee",
    "https://secrets-dev.dotv.ee",
]
export defaultSecretManagerChoice = 0

############################################################
# Secret Manager
export dataManagerOptions = [
    "https://data.dotv.ee",
    "https://data-dev.dotv.ee",
]
export defaultDataManagerChoice = 1

############################################################
# KrakenObserver Backend
export krakenObserverBackendOptions = [
    "https://kraken-observer.dotv.ee",
    "https://localhost:6999",
    "https://localhost:6969"
]
export defaultKrakenObserverBackendOption = 3


############################################################
# Situation Analyzer Backend
export situationAnalyzerBackendOptions = [
    "https://situation-analyzer.dotv.ee",
    "https://localhost:6999",
    "https://localhost:6969"
]
export defaultSituationAnalyzerBackendOption = 2

############################################################
