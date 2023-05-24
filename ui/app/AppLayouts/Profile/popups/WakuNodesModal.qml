import QtQuick 2.12
import QtQuick.Controls 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import "."

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0

StatusModal {
    id: root

    anchors.centerIn: parent
    height: 560
    padding: 8
    header.title: qsTr("Waku nodes")

    property var messagingStore
    property var advancedStore
    
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
                text: qsTr("Add a new node")
                color: Theme.palette.primaryColor1
                width: parent.width
                MouseArea {
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
