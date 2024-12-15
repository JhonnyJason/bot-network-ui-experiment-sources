simpleVolatilityTrader = {
    type: "volatility0"
    name: "Simple Volatility Trader v0.1"
    assetSlots: 2
    defaultParams: {
        baseDistancePercent: 0.6
        backOrderDistancePercent: 1.8
        volumeMagnifier: 2.718
        priceMagnifier: 1.618
        volumePrecision: 2
        pricePrecision: 2
        buyDirection: true
        sellDirection: true
    }
}

simpleBalanceTrader = {
    type: "balance0"
    name: "Simple Balance Trader v0.1"
    assetSlots: 2
    defaultParams: {
        inbalanceTolerancePercent: 5
    }
}

freakyRandomTrader = {
    type: "random0"
    name: "Freaky Random Trader v0.1"
    assetSlots: 2
    defaultParams: {
        crazyness: 5
    }
}


export afControllers = [
    simpleVolatilityTrader,
    simpleBalanceTrader,
    freakyRandomTrader
]