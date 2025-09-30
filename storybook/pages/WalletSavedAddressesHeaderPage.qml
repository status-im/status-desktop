import QtCore
import QtQml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Wallet.controls
import AppLayouts.Wallet.panels

import shared.stores

import Storybook
import utils

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        SplitView.fillHeight: true

        WalletSavedAddressesHeader {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            lastReloadedTime: new Date().toString()
            loading: loadingCheckBox.checked

            onReloadRequested: logs.logEvent("reloadRequested")
            onAddNewAddressClicked: logs.logEvent("addNewAddressClicked")
        }
    }

    LogsAndControlsPanel {
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        CheckBox {
            id: loadingCheckBox

            text: "loading"
        }
    }

    Settings {
        property alias loading: loadingCheckBox.checked
    }
}

// category: Panels
// status: good
