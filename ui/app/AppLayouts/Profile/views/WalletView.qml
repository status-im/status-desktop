import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "../stores"
import "../controls"
import "../popups"
import "../panels"
import "./wallet"

ScrollView {
    id: root

    property int profileContentWidth

    height: parent.height
    width: parent.width
    contentHeight: advancedContainer.height + 100
    clip: true

    property WalletStore walletStore

    Item {
        id: advancedContainer
        width: profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        height: stackContainer.height
        
        StackLayout {
            id: stackContainer

            anchors.fill: parent

            currentIndex: 0

            onCurrentIndexChanged: {
                if(visibleChildren[0] === ensContainer){
                    ensContainer.goToStart();
                }
            }

            MainView {
                walletStore: root.walletStore
                onGoToNetworksView: {
                    stackContainer.currentIndex = 1
                }
            }

            NetworksView {
                walletStore: root.walletStore
                anchors.fill: parent
                onGoBack: {
                    stackContainer.currentIndex = 0
                }
            }
        }
    }
}
