import QtQuick 2.15
import QtQuick.Controls 2.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.popups 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !buySellModal.visible

            onClicked: buySellModal.open()
        }

        BuyCryptoModal {
            id: buySellModal
            visible: true
            onRampProvidersModel: OnRampProvidersModel{}
        }
    }
}

// category: Popups
