import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import QtQml

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups.Dialog

import shared.controls
import shared.popups
import utils

StatusDialog {
    id: root

    required property string communityName
    required property int shardIndex
    required property string pubsubTopic

    signal disableShardingRequested()
    signal editShardIndexRequested()

    title: qsTr("Manage community sharding for %1").arg(communityName)
    width: 640

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusFlatButton {
                type: StatusBaseButton.Type.Danger
                text: qsTr("Disable community sharding")
                onClicked: confirmationPopup.open()
            }
            StatusButton {
                text: qsTr("Edit shard number")
                onClicked: {
                    root.editShardIndexRequested()
                    root.close()
                }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Theme.halfPadding

        StatusBaseText {
            text: qsTr("Shard number")
        }

        StatusTextArea {
            Layout.fillWidth: true
            readOnly: true
            text: root.shardIndex
        }

        StatusBaseText {
            Layout.topMargin: Theme.halfPadding
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
    }

    ConfirmationDialog {
        id: confirmationPopup
        width: root.width - root.margins
        anchors.centerIn: parent
        headerSettings.title: qsTr("Are you sure you want to disable sharding?")
        showCancelButton: true
        cancelBtnType: ""
        confirmationText: qsTr("Are you sure you want to disable community sharding? Your community will automatically revert to using the general shared Waku network.")
        confirmButtonLabel: qsTr("Disable community sharding")
        onCancelButtonClicked: close()
        onConfirmButtonClicked: {
            close()
            root.disableShardingRequested()
            root.close()
        }
    }
}
