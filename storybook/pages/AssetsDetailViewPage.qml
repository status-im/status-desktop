import QtQuick
import QtQuick.Layouts

import AppLayouts.Wallet.views
import AppLayouts.Wallet.stores as WalletStores

import shared.stores as SharedStores

import utils

import Models
import Mocks

Item {
    id: root


    AssetsDetailView {
        anchors.fill: parent

        tokensStore: TokensStoreMock {}
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

        tokenGroup: ({
            key: Constants.sntGroupKey,
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
