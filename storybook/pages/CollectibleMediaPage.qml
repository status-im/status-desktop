import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import AppLayouts.Communities.stores as CommunitiesStores
import AppLayouts.Wallet
import AppLayouts.Wallet.stores as WalletStores
import AppLayouts.Wallet.views.collectibles

import StatusQ.Core.Utils

import shared.controls
import shared.stores as SharedStores

import Models
import utils

SplitView {
    id: root

    // QtObject {
    //     function isValidURL(url) {
    //         return true
    //     }

    //     Component.onCompleted: {
    //         Utils.globalUtilsInst = this
    //     }
    //     Component.onDestruction: {
    //         Utils.globalUtilsInst = {}
    //     }
    // }

    QtObject {
        id: d

        readonly property QtObject collectiblesModel: ManageCollectiblesModel {
            Component.onCompleted: {
                d.refreshCurrentCollectible()
            }
        }
        property var currentCollectible

        function refreshCurrentCollectible() {
            currentCollectible = ModelUtils.get(collectiblesModel, collectibleComboBox.currentIndex)
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.fill: viewLoader
                anchors.margins: -1
                color: "transparent"
                border.width: 1
                border.color: "#808080"
            }

            Loader {
                id: viewLoader
                anchors.fill: parent
                anchors.margins: 50

                active: false

                sourceComponent: CollectibleMedia {
                    backgroundColor: d.currentCollectible.backgroundColor ? d.currentCollectible.backgroundColor : "transparent"
                    isCollectibleLoading: isLoadingCheckbox.checked
                    mediaUrl: d.currentCollectible.mediaUrl ?? ""
                    fallbackImageUrl: d.currentCollectible.imageUrl
                    interactive: isInteractiveCheckbox.checked
                    enabled: isEnabledCheckbox.checked
                }
                Component.onCompleted: viewLoader.active = true
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            SplitView.fillWidth: true
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            Label {
                text: "Collectible:"
            }
            ComboBox {
                id: collectibleComboBox
                Layout.fillWidth: true
                textRole: "name"
                model: d.collectiblesModel
                currentIndex: 0
                onCurrentIndexChanged: d.refreshCurrentCollectible()
            }
            CheckBox { // Loading state when model is loading, it doesn't affect internal image loading state
                id: isLoadingCheckbox
                text: "isLoading"
                checked: false
            }
            CheckBox {
                id: isInteractiveCheckbox
                text: "isInteractive"
                checked: true
            }
            CheckBox {
                id: isEnabledCheckbox
                text: "isEnabled"
                checked: true
            }
        }
    }
}

// category: Wallet
// status: good
