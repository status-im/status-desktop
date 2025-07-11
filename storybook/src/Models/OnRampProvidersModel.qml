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
                { key: "111551110x0000000000000000000000000000000000000000",  chainId: 11155111, address: "0x0000000000000000000000000000000000000000"},
                { key: "4200x0000000000000000000000000000000000000000", chainId: 11155420, address: "0x0000000000000000000000000000000000000000"},
                { key: "4200xf2edf1c091f683e3fb452497d9a98a49cba84669", chainId: 11155420, address: "0xf2edf1c091f683e3fb452497d9a98a49cba84669"},
            ],
            urlsNeedParameters: true
        }
    ]

    Component.onCompleted: append(data)
}
