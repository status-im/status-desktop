import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import StatusQ.Core.Theme 0.1

Control {
    id: root

    property bool closeEnabled: true
    property bool buyEnabled: true
    property bool receiveEnabled: true

    readonly property bool anyVisibleItems: buyCard.visible || receiveCard.visible

    signal buyClicked()
    signal receiveClicked()
    signal closeBuy()
    signal closeReceive()

    contentItem: RowLayout {
        id: layout
        spacing: Theme.padding

        BannerCard {
            id: buyCard
            objectName: "buyCard"
            Layout.fillWidth: true
            Layout.preferredWidth: root.buyEnabled ? layout.width / layout.children.length : 0
            title: qsTr("Ways to buy crypto")
            subTitle: qsTr("Via card or bank transfer")
            image: Theme.png("wallet/wallet-green")
            closeEnabled: root.closeEnabled
            visible: Layout.preferredWidth > 0
            opacity: root.buyEnabled ? 1 : 0

            onClose: root.closeBuy()
            onClicked: root.buyClicked()

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
        BannerCard {
            id: receiveCard
            objectName: "receiveCard"
            Layout.fillWidth: true
            Layout.preferredWidth: root.receiveEnabled ? layout.width / layout.children.length : 0
            title: qsTr("Receive crypto")
            subTitle: qsTr("Deposit to your Wallet address")
            image: Theme.png("wallet/flying-coin")
            closeEnabled: root.closeEnabled
            visible: Layout.preferredWidth > 0
            opacity: root.receiveEnabled ? 1 : 0

            onClose: root.closeReceive()
            onClicked: root.receiveClicked()

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
    }
}