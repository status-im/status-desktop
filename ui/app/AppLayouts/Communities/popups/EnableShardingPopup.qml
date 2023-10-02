import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import utils 1.0

StatusStackModal {
    id: root

    required property string communityName
    required property string publicKey
    property int initialShardIndex: -1
    property bool shardingInProgress

    signal enableSharding(int shardIndex)

    stackTitle: qsTr("Enable community sharding for %1").arg(communityName)
    width: 640

    readonly property var cancelButton: StatusFlatButton {
        text: qsTr("Cancel")
        onClicked: root.close()
    }

    nextButton: StatusButton {
        text: qsTr("Next")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        loading: root.shardingInProgress
        onClicked: {
            let nextAction = currentItem.nextAction
            if (typeof(nextAction) == "function") {
                return nextAction()
            }
            root.currentIndex++
        }
    }

    finishButton: StatusButton {
        text: qsTr("Enable community sharding")
        enabled: typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext
        onClicked: {
            root.enableSharding(d.shardIndex)
            root.close()
        }
    }

    rightButtons: [cancelButton, nextButton, finishButton]

    QtObject {
        id: d
        readonly property string pubSubTopic: '{"pubsubTopic":"/waku/2/rs/16/%1", "publicKey":"%2"}'.arg(shardIndex).arg(root.publicKey) // FIXME backend
        property int shardIndex: root.initialShardIndex
    }

    onAboutToShow: shardIndexEdit.focus = true

    stackItems: [
        ColumnLayout {
            id: firstPage
            spacing: Style.current.halfPadding

            readonly property bool canGoNext: shardIndexEdit.valid
            readonly property var nextAction: function () {
                d.shardIndex = parseInt(shardIndexEdit.text)
                root.currentIndex++
            }

            StatusInput {
                id: shardIndexEdit
                Layout.fillWidth: true
                label: qsTr("Enter shard number")
                placeholderText: qsTr("Enter a number between 0 and 1023")
                text: d.shardIndex !== -1 ? d.shardIndex : ""
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
            readonly property bool canGoNext: agreement.checked

            StatusBaseText {
                text: qsTr("Pub/Sub topic")
            }

            StatusTextArea {
                Layout.fillWidth: true
                Layout.preferredHeight: 138
                readOnly: true
                text: d.pubSubTopic
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
