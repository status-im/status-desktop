import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Popups

import "."

import utils
import shared
import shared.panels
import shared.popups
import shared.status
import shared.controls

import AppLayouts.Profile.stores

StatusModal {
    id: root

    anchors.centerIn: parent
    height: 560
    padding: 8
    headerSettings.title: qsTr("Waku nodes")

    property MessagingStore messagingStore
    property AdvancedStore advancedStore
    
    onClosed: {
        destroy()
    }
    
    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        Column {
            id: nodesColumn
            width: scrollView.availableWidth

            Repeater {
                id: wakunodesListView
                model: root.messagingStore.wakunodes
                delegate: Component {
                    StatusListItem {
                        width: parent.width
                        title: qsTr("Node %1").arg(index + 1)
                        subTitle: model.nodeAddress
                        components: [
                            // TODO: add a button to delete nodes and restore default fleet nodes if necessary
                        ]
                    }
                }
            }

            StatusBaseText {
                visible: false // FIXME: hide for now (https://github.com/status-im/status-go/issues/5597)
                text: qsTr("Add a new node")
                color: Theme.palette.primaryColor1
                width: parent.width
                StatusMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Global.openPopup(wakuNodeModalComponent)
                }
            }
        }
    }

    Component {
        id: wakuNodeModalComponent
        AddWakuNodeModal {
            messagingStore: root.messagingStore
            advancedStore: root.advancedStore
        }
    }
}
