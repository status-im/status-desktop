import QtQuick
import QtQuick.Controls

import AppLayouts.Profile.controls
import StatusQ.Core
import utils

import Models
import Storybook

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d

        readonly property QtObject walletStore: QtObject {
            property string userProfilePublicKey: "zq3shfrgk6swgrrnc7wmwun1gvgact9iaevv9xwirumimhbyf"

            function getAllNetworksSupportedString(hovered) {
                return hovered ?  "<font color=\"" + "#627EEA" + "\">" + "eth:" + "</font>" +
                                 "<font color=\"" + "#E90101" + "\">" + "oeth:" + "</font>" +
                                 "<font color=\"" + "#27A0EF" + "\">" + "arb1:" + "</font>" : "eth:oeth:arb1:"
            }
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusListView {
            width: 500
            height: parent.height
            anchors.verticalCenterOffset: 20
            anchors.centerIn: parent
            spacing: 24
            model: WalletKeyPairModel {}
            delegate: WalletKeyPairDelegate {
                width: parent.width
                keyPair: model.keyPair
                userProfilePublicKey: d.walletStore.userProfilePublicKey
                onGoToAccountView: console.warn("onGoToAccountView ::")
            }
        }
    }
}

// category: Wallet
