import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.views
import mainui

import Storybook
import Models

import AppLayouts.stores as AppLayoutStores
import shared.stores as SharedStores

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property int assetType: 1
    readonly property int collectibleType: 2

    Logs { id: logs }

    Popups {
        popupParent: root
        sharedRootStore: SharedStores.RootStore {}
        rootStore: AppLayoutStores.RootStore {}
        communityTokensStore: SharedStores.CommunityTokensStore {}
        utilsStore: SharedStores.UtilsStore {}
        networksStore: SharedStores.NetworksStore {}
    }

    QtObject {
        id: notificationMock

        property int timestamp: Date.now()
    }

    QtObject {
        id: communityMock

        property string id: "11"
        property string name: "Doodles"
        property string image: ModelsData.banners.status
    }

    QtObject {
        id: assetMock

        property string amount: "2.5"
        property string name: "dai"
        property string symbol: "DAI"
        property string image: ModelsData.assets.dai
    }


    QtObject {
        id: collectibleMock

        property string amount: "4"
        property string name: "doodles"
        property string symbol: "DOOD"
        property string image: ModelsData.banners.status
    }

    ColumnLayout {
        SplitView.fillHeight: true
        SplitView.fillWidth: true

        ActivityNotificationCommunityTokenReceived {

            Layout.fillWidth: true
            Layout.margins: 16

            // Community properties:
            communityId: communityMock.id
            communityName: communityMock.name
            communityImage: communityMock.image

            // Notification type related properties:
            isFirstTokenReceived: true
            tokenType: root.assetType

            // Token related properties:
            tokenAmount: assetMock.amount
            tokenName: assetMock.name
            tokenSymbol: assetMock.symbol
            tokenImage: assetMock.image

            // Wallet related:
            walletAccountName: "My wallet"
            txHash: "0x01231232"

            notification: notificationMock
        }

        ActivityNotificationCommunityTokenReceived {

            Layout.fillWidth: true
            Layout.margins: 16

            // Community properties:
            communityId: communityMock.id
            communityName: communityMock.name
            communityImage: communityMock.image

            // Notification type related properties:
            isFirstTokenReceived: false
            tokenType: root.assetType

            // Token related properties:
            tokenAmount: assetMock.amount
            tokenName: assetMock.name
            tokenSymbol: assetMock.symbol
            tokenImage: assetMock.image

            // Wallet related:
            walletAccountName: "My wallet 2"
            txHash: "0x01231232"

            notification: notificationMock
        }

        ActivityNotificationCommunityTokenReceived {

            Layout.fillWidth: true
            Layout.margins: 16

            // Community properties:
            communityId: communityMock.id
            communityName: communityMock.name
            communityImage: communityMock.image

            // Notification type related properties:
            isFirstTokenReceived: true
            tokenType: root.assetType

            // Token related properties:
            tokenAmount: collectibleMock.amount
            tokenName: collectibleMock.name
            tokenSymbol: collectibleMock.symbol
            tokenImage: collectibleMock.image

            // Wallet related:
            walletAccountName: "The wallet account"
            txHash: "0x01231232"

            notification: notificationMock
        }

        ActivityNotificationCommunityTokenReceived {

            Layout.fillWidth: true
            Layout.margins: 16

            // Community properties:
            communityId: communityMock.id
            communityName: communityMock.name
            communityImage: communityMock.image

            // Notification type related properties:
            isFirstTokenReceived: false
            tokenType: root.collectibleType

            // Token related properties:
            tokenAmount: collectibleMock.amount
            tokenName: collectibleMock.name
            tokenSymbol: collectibleMock.symbol
            tokenImage: collectibleMock.image

            // Wallet related:
            walletAccountName: "Collectibles wallet"
            txHash: "0x01231232"

            notification: notificationMock
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}

// category: Activity Center
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18700%3A276619&mode=design&t=8r02XS6eFbmDWKa1-1
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20765%3A244315&mode=design&t=WV4rxtOEDUDl4aZ6-1
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20765%3A398956&mode=design&t=EGnLxrqE9kqaWGP4-1
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20787%3A74840&mode=design&t=EGnLxrqE9kqaWGP4-1
