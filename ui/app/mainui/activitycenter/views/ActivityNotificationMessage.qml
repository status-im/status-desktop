import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import utils 1.0

ActivityNotificationBase {
    id: root

    readonly property string timestampString: new Date(notification.timestamp).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
    readonly property string timestampTooltipString: new Date(notification.timestamp).toLocaleString()

    property int maximumLineCount: 2

    signal messageClicked()

    property StatusMessageDetails messageDetails: StatusMessageDetails {
        messageText: notification.message.messageText
        amISender: notification.message.amISender
        sender.id: notification.message.senderId
        sender.displayName: notification.message.senderDisplayName
        sender.secondaryName: notification.message.senderOptionalName
        sender.trustIndicator: notification.message.senderTrustStatus
        sender.profileImage {
            width: 40
            height: 40
            name: notification.message.senderIcon || ""
            assetSettings.isImage: notification.message.senderIcon.startsWith("data")
            pubkey: notification.message.senderId
            colorId: Utils.colorIdForPubkey(notification.message.senderId)
            colorHash: Utils.getColorHashAsJson(notification.message.senderId, false, true)
            showRing: true
        }
    }

    property Component messageSubheaderComponent: null
    property Component messageBadgeComponent: null

    function openProfilePopup() {
        closeActivityCenter()
        Global.openProfilePopup(notification.message.senderId)
    }
    bodyComponent: MouseArea {
        hoverEnabled: root.messageBadgeComponent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.messageClicked()
        height: messageRow.implicitHeight
        RowLayout {
            id: messageRow
            spacing: 8
            width: parent.width

            Item {
                Layout.preferredWidth: root.messageDetails.sender.profileImage.assetSettings.width
                Layout.preferredHeight: profileImage.height
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: Style.current.padding
                Layout.topMargin: 2

                StatusSmartIdenticon {
                    id: profileImage
                    name: root.messageDetails.sender.displayName
                    asset: root.messageDetails.sender.profileImage.assetSettings
                    ringSettings: root.messageDetails.sender.profileImage.ringSettings

                    MouseArea {
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        onClicked: root.openProfilePopup()
                    }
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
                    timestamp.text: root.timestampString
                    timestamp.tooltip.text: root.timestampTooltipString
                    onClicked: root.openProfilePopup()
                }

                Loader {
                    sourceComponent: root.messageSubheaderComponent
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    StatusBaseText {
                        text: CoreUtils.Utils.stripHtmlTags(root.messageDetails.messageText)
                        maximumLineCount: root.maximumLineCount
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        font.pixelSize: 15
                        Layout.alignment: Qt.AlignVCenter
                        Layout.maximumWidth: 400 // From designs, fixed value to align all possible CTAs
                    }

                    Loader {
                        sourceComponent: root.messageBadgeComponent
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
