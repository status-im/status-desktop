import QtQuick 2.15

ListModel {
    readonly property var data: [
        {
            name:              "Ramp",
            description:       "Global crypto to fiat flow",
            fees:              "0.49% - 2.9%",
            logoUrl:           ModelsData.onRampProviderImages.ramp,
            siteUrl:           "https://ramp.network/buy?hostApiKey=zrtf9u2uqebeyzcs37fu5857tktr3eg9w5tffove&swapAsset=DAI,ETH,USDC,USDT",
            hostname:          "ramp.network",
            recurrentSiteURL:  ""
        },
        {
            name:              "MoonPay",
            description:       "The new standard for fiat to crypto",
            fees:              "1% - 4.5%",
            logoUrl:           ModelsData.onRampProviderImages.moonPay,
            siteUrl:           "https://buy.moonpay.com/?apiKey=pk_live_YQC6CQPA5qqDu0unEwHJyAYQyeIqFGR",
            hostname:          "moonpay.com",
            recurrentSiteURL:  "https://buy.moonpay.com/?apiKey=pk_live_YQC6CQPA5qqDu0unEwHJyAYQyeIqFGR",
        },
        {
            name:              "Latamex",
            description:       "Easily buy crypto in Argentina, Mexico, and Brazil",
            fees:              "1% - 1.7%",
            logoUrl:           ModelsData.onRampProviderImages.latamex,
            siteUrl:           "https://latamex.com/",
            hostname:          "latamex.com",
            recurrentSiteURL:  "",
        }
    ]

    Component.onCompleted: append(data)
}
