import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Profile.controls 1.0

import StatusQ.Core 0.1

import utils 1.0

import Storybook 1.0

import Models 1.0

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
                                 "<font color=\"" + "#E90101" + "\">" + "opt:" + "</font>" +
                                 "<font color=\"" + "#27A0EF" + "\">" + "arb:" + "</font>" : "eth:opt:arb:"
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
                chainShortNames: d.walletStore.getAllNetworksSupportedString()
                userProfilePublicKey: d.walletStore.userProfilePublicKey
                onGoToAccountView: console.warn("onGoToAccountView ::")
            }
        }
    }
}
