import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

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
    property string timestampString
    property string timestampTooltipString

    signal accepted
    signal declined

    anchors.centerIn: parent
    width: 638
    padding: Style.current.bigPadding

    title: qsTr("Review Contact Request")
    RowLayout {
        id: messageRow
        spacing: 8
        width: parent.width

        Item {
            Layout.preferredWidth: root.messageDetails.sender.profileImage.assetSettings.width
            Layout.preferredHeight: profileImage.height
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: -Style.current.halfPadding
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
                tertiaryDetail: Utils.getElidedCompressedPk(sender.id)
                timestamp.text: root.timestampString
                timestamp.tooltip.text: root.timestampTooltipString
            }

            RowLayout {
                spacing: 2
                Layout.fillWidth: true

                StatusBaseText {
                    text: CoreUtils.Utils.stripHtmlTags(root.messageDetails.messageText)
                    wrapMode: Text.Wrap
                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.rightMargin: -Style.current.halfPadding
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
