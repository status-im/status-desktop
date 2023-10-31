import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0
import shared.popups 1.0
import utils 1.0

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
        spacing: Style.current.halfPadding

        StatusBaseText {
            text: qsTr("Shard number")
        }

        StatusTextArea {
            Layout.fillWidth: true
            readOnly: true
            text: root.shardIndex
        }

        StatusBaseText {
            Layout.topMargin: Style.current.halfPadding
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
