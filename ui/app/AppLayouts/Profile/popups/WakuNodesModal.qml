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
    id: popup

    anchors.centerIn: parent
    height: Style.dp(560)
    header.title: qsTr("Waku nodes")

    property var messagingStore
    property string nameValidationError: ""
    property string enodeValidationError: ""

    onClosed: {
        destroy()
    }
    
    contentItem: ScrollView {
        height: parent.height
        width: parent.width
        contentHeight: nodesColumn.height
        clip: true

        Column {
            id: nodesColumn
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding

            StatusListItem {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                title: qsTr("Use Waku nodes")
                components: [
                    StatusSwitch {
                        checked: root.messagingStore.useMailservers
                        onCheckedChanged: root.messagingStore.toggleUseMailservers(checked)
                    }
                ]
                sensor.onClicked: {
                    root.messagingStore.toggleUseMailservers(!root.messagingStore.useMailservers)
                }
            }

            Separator {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
            }

            StatusListItem {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                title: qsTr("Select node automatically")
                components: [
                    StatusSwitch {
                        id: automaticSelectionSwitch
                        checked: root.messagingStore.automaticMailserverSelection
                        onCheckedChanged: root.messagingStore.enableAutomaticMailserverSelection(checked)
                    }
                ]
                sensor.onClicked: {
                    automaticSelectionSwitch.checked = !automaticSelectionSwitch.checked
                }
            }

            StatusSectionHeadline {
                text: qsTr("Waku Nodes")
                visible: !automaticSelectionSwitch.checked
                width: parent.width
                height: visible ? implicitHeight : 0
            }

            ButtonGroup {
                id: nodesButtonGroup
            }

            Repeater {
                id: mailServersListView
                model: root.messagingStore.mailservers
                delegate: Component {
                    StatusListItem {
                        title: qsTr("Node %1").arg(index)
                        subTitle: model.name
                        visible: !automaticSelectionSwitch.checked
                        height: visible ? implicitHeight : 0
                        components: [
                            StatusRadioButton {
                                id: nodeRadioBtn
                                ButtonGroup.group: nodesButtonGroup
                                checked: model.nodeAddress === root.messagingStore.activeMailserver
                                onCheckedChanged: {
                                     if (checked) {
                                        root.messagingStore.setActiveMailserver(model.nodeAddress)
                                    }
                                }
                            }
                        ]
                        sensor.onClicked: {
                            nodeRadioBtn.checked = true
                        }
                    }
                }
            }

            StatusBaseText {
                text: qsTr("Add a new node")
                color: Theme.palette.primaryColor1

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
        }
    }
}
