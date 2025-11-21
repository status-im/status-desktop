import QtQuick
import QtQuick.Controls

import StatusQ.Core.Theme
import AppLayouts.Wallet.popups
import shared.stores as SharedStores
import Storybook

import utils

SplitView {
    Logs { id: logs }

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Component.onCompleted: popup.open()

        SavedAddressActivityPopup {
            id: popup

            visible: true
            destroyOnClose: true
            modal: false
            closePolicy: Popup.NoAutoClose
            networksStore: SharedStores.NetworksStore {}

            Component.onCompleted: {
                initWithParams({
                                   name: "Noelia Santos",
                                   address: "0xe5bd6c877cd566af2a58990ad0ed4b73fb0c6752",
                                   ens: "",
                                   colorId: Utils.getIdForColor(Theme.palette.customisationColors.blue),
                                   mixedcaseAddress: "0xe5bD6C877cd566Af2a58990Ad0eD4B73fb0c6752",
                               })
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Popups
