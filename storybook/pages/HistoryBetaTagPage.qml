import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import Storybook
import utils

import shared.views
import shared.stores as SharedStores

SplitView {
    id: root

    orientation: Qt.Horizontal


    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        HistoryBetaTag {
            anchors.centerIn: parent
            property SharedStores.NetworksStore networksStore: SharedStores.NetworksStore {
                id: networksStore
                areTestNetworksEnabled: testModeCheckBox.checked
            }
            flatNetworks: networksStore.activeNetworks

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 0
            Layout.preferredHeight: 56

            onLinkActivated: {
                console.log("linkActivated", link)
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            spacing: 16

            CheckBox {
                id: testModeCheckBox
                text: "Testnet mode"
                checked: false
            }
        }
    }
}

// category: Views