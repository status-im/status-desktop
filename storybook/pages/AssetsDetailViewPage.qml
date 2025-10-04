import QtQuick
import QtQuick.Layouts

import AppLayouts.Wallet.views
import AppLayouts.Wallet.stores as WalletStores

import shared.stores as SharedStores

import Models

Item {
    id: root


    AssetsDetailView {
        anchors.fill: parent

        tokensStore: WalletStores.TokensStore {}
        currencyStore: SharedStores.CurrenciesStore {}
        networkConnectionStore: SharedStores.NetworkConnectionStore {}

        networkFilters: NetworksModel.mainnetChainId + ":" +
                        NetworksModel.sepMainnetChainId

        ListModel {
            id: addressPerChainModel

            Component.onCompleted: {
                append([
                    {
                        chainId: NetworksModel.mainnetChainId
                    },
                    {
                        chainId: NetworksModel.sepMainnetChainId
                    }
                ])
            }
        }

        allNetworksModel: NetworksModel.flatNetworks

        token: ({
            websiteUrl: "https://status.im",
            symbol: "SNT",
            name: "Status",
            balanceText: "123 SNT",
            balance: 123,
            marketPrice: 2.3,
            description: "Some token description",
            addressPerChain: addressPerChainModel,
           // communityId: "1",
            communityName: "Some community",
            communityImage: ModelsData.icons.rarible
        })
    }
}

// category: Views
// status: good
