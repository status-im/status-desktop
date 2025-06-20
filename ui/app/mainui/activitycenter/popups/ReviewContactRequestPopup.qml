import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import shared 1.0
import utils 1.0

StatusDialog {
    id: root

    property StatusMessageDetails messageDetails
    property string compressedPubKey
    property double timestamp: 0

    signal accepted
    signal declined

    anchors.centerIn: parent
    width: 638
    padding: Theme.bigPadding

    title: qsTr("Review Contact Request")
    RowLayout {
        id: messageRow
        spacing: 8
        width: parent.width

        Item {
            Layout.preferredWidth: root.messageDetails.sender.profileImage.assetSettings.width
            Layout.preferredHeight: profileImage.height
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: -Theme.halfPadding
            Layout.topMargin: 2

            StatusSmartIdenticon {
                id: profileImage
                name: root.messageDetails.sender.displayName
                asset: root.messageDetails.sender.profileImage.assetSettings
                ringSettings: root.messageDetails.sender.profileImage.ringSettings
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            StatusMessageHeader {
                sender: root.messageDetails.sender
                amISender: root.messageDetails.amISender
                messageOriginInfo: root.messageDetails.messageOriginInfo
                tertiaryDetail: root.compressedPubKey
                timestamp: root.timestamp
            }

            RowLayout {
                spacing: 2
                Layout.fillWidth: true

                StatusBaseText {
                    text: CoreUtils.Utils.stripHtmlTags(root.messageDetails.messageText)
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.primaryTextFontSize
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.rightMargin: -Theme.halfPadding
                }
            }
        }
    }
    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Accept Contact Request")
                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
            StatusButton {
                type: StatusBaseButton.Type.Danger
                text: qsTr("Reject Contact Request")
                onClicked: {
                    root.declined()
                    root.close()
                }
            }
        }
    }
}
