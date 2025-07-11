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
    headerSettings.title: qsTr("History Nodes")

    property MessagingStore messagingStore
    property AdvancedStore advancedStore
    property string nameValidationError: ""
    property string enodeValidationError: ""

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

            StatusListItem {
                width: parent.width
                title: qsTr("Use Waku nodes")
                components: [
                    StatusSwitch {
                        checked: root.messagingStore.useMailservers
                        onCheckedChanged: root.messagingStore.toggleUseMailservers(checked)
                    }
                ]
                onClicked: {
                    root.messagingStore.toggleUseMailservers(!root.messagingStore.useMailservers)
                }
            }

            Separator {
               width: parent.width
            }

            StatusListItem {
                width: parent.width
                title: qsTr("Select node automatically")
                components: [
                    StatusSwitch {
                        id: automaticSelectionSwitch
                        checked: root.messagingStore.automaticMailserverSelection
                        onCheckedChanged: root.messagingStore.enableAutomaticMailserverSelection(checked)
                    }
                ]
                onClicked: {
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
                        title: qsTr("Node %1").arg(index + 1)
                        subTitle: model.name
                        visible: !automaticSelectionSwitch.checked
                        height: visible ? implicitHeight : 0
                        components: [
                            StatusRadioButton {
                                id: nodeRadioBtn
                                ButtonGroup.group: nodesButtonGroup
                                checked: model.name === root.messagingStore.pinnedMailserverId
                                onCheckedChanged: {
                                     if (checked) {
                                         root.messagingStore.setPinnedMailserverId(model.name)
                                    }
                                }
                            }
                        ]
                        onClicked: {
                            nodeRadioBtn.checked = true
                        }
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
