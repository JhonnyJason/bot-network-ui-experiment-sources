simpleVolatilityTrader = {
    name: "Simple Volatility Trader"
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
    name: "Simple Balance Trader"
    assetSlots: 2
    defaultParams: {
        inbalanceTolerancePercent: 5
    }
}


export afControllers = [
    simpleVolatilityTrader,
    simpleBalanceTrader
]