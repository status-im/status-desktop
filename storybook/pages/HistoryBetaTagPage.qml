import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import Storybook 1.0
import utils 1.0

import shared.views 1.0
import shared.stores 1.0 as SharedStores

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