import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Components
import StatusQ.Popups

import shared.controls
import utils

StatusStackModal {
    id: root

    required property string communityName
    required property int shardIndex
    required property string pubsubTopic
    property bool shardingInProgress

    stackTitle: qsTr("Enable community sharding for %1").arg(communityName)
    width: 640

    readonly property var cancelButton: StatusFlatButton {
        visible: typeof(currentItem.canGoNext) == "undefined" || currentItem.cancellable
        text: qsTr("Cancel")
        onClicked: root.close()
    }

    nextButton: StatusButton {
        text: qsTr("Enable community sharding")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        loading: root.shardingInProgress
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof(nextAction) == "function") {
                return nextAction()
            }
        }
    }

    finishButton: StatusButton {
        text: qsTr("Close")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            root.currentIndex = 0
            root.close()
        }
    }

    rightButtons: [cancelButton, nextButton, finishButton]

    onAboutToShow: shardIndexEdit.focus = !SQUtils.Utils.isMobile
    onShardingInProgressChanged: if (!root.shardingInProgress && root.currentIndex == 0) {
        root.currentIndex++
    }

    stackItems: [
        ColumnLayout {
            id: firstPage
            spacing: Theme.halfPadding

            readonly property bool cancellable: true
            readonly property bool canGoNext: shardIndexEdit.valid && root.shardIndex != parseInt(shardIndexEdit.text)
            readonly property var nextAction: function () {
                root.shardIndex = parseInt(shardIndexEdit.text)
            }

            StatusInput {
                id: shardIndexEdit
                Layout.fillWidth: true
                label: qsTr("Enter shard number")
                placeholderText: qsTr("Enter a number between 0 and 1023")
                text: root.shardIndex !== -1 ? root.shardIndex : ""
                validators: [
                    StatusIntValidator {
                        bottom: 0
                        top: 1023
                        errorMessage: qsTr("Invalid shard number. Number must be 0 — 1023.")
                    }
                ]
                Keys.onPressed: {
                    if (!shardIndexEdit.valid)
                        return
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        event.accepted = true
                        firstPage.nextAction()
                    }
                }
            }
        },
        ColumnLayout {
            readonly property bool cancellable: false
            readonly property bool canGoNext: agreement.checked

            StatusBaseText {
                text: qsTr("Pub/Sub topic")
            }

            StatusTextArea {
                Layout.fillWidth: true
                Layout.preferredHeight: 138
                readOnly: true
                text: root.pubsubTopic
                rightPadding: 48
                wrapMode: TextEdit.Wrap

                CopyButton {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: 12
                    anchors.topMargin: 10
                    textToCopy: parent.text
                }
            }

            StatusCheckBox {
                id: agreement
                text: qsTr("I have made a copy of the Pub/Sub topic and public key string")
            }
        }
    ]
}
