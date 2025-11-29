import QtQuick

ListModel {
    readonly property var data: [
        {
            id: "1",
            name:              "Ramp",
            description:       "Global crypto to fiat flow",
            fees:              "0.49% - 2.9%",
            logoUrl:           ModelsData.onRampProviderImages.ramp,
            hostname:          "ramp.network",
            supportsSinglePurchase: true,
            supportsRecurrentPurchase: false,
            supportedAssets:[],
            urlsNeedParameters: false
        },
        {
            id: "2",
            name:              "MoonPay",
            description:       "The new standard for fiat to crypto",
            fees:              "1% - 4.5%",
            logoUrl:           ModelsData.onRampProviderImages.moonPay,
            hostname:          "moonpay.com",
            supportsSinglePurchase: true,
            supportsRecurrentPurchase: false,
            supportedAssets:[],
            urlsNeedParameters: false
        },
        {
            id: "3",
            name:              "Latamex",
            description:       "Easily buy crypto in Argentina, Mexico, and Brazil",
            fees:              "1% - 1.7%",
            logoUrl:           ModelsData.onRampProviderImages.latamex,
            hostname:          "latamex.com",
            supportsSinglePurchase: true,
            supportsRecurrentPurchase: false,
            supportedAssets:[],
            urlsNeedParameters: false
        },
        {
            id: "4",
            name:              "Mercuryo",
            description:       "Mercuryo buy crypto in Argentina, Mexico, and Brazil",
            fees:              "1% - 1.7%",
            logoUrl:           ModelsData.onRampProviderImages.mercuryo,
            hostname:          "mercuryo.com",
            supportsSinglePurchase: true,
            supportsRecurrentPurchase: true,
            supportedAssets:[
                { key: "11155111-0x0000000000000000000000000000000000000000",  chainId: 11155111, address: "0x0000000000000000000000000000000000000000"},
                { key: "11155420-0x0000000000000000000000000000000000000000", chainId: 11155420, address: "0x0000000000000000000000000000000000000000"},
                { key: "11155111-0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6", chainId: 11155111, address: "0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6"},
            ],
            urlsNeedParameters: true
        }
    ]

    Component.onCompleted: append(data)
}
