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

    readonly property string timestampString: notification ?
                new Date(notification.timestamp).toLocaleTimeString(Qt.locale(), Locale.ShortFormat) : ""
    readonly property string timestampTooltipString: notification ?
                new Date(notification.timestamp).toLocaleString() : ""
    readonly property bool isOutgoingRequest: notification && notification.message.amISender
    readonly property string contactId: notification ? isOutgoingRequest ? notification.chatId : notification.author : ""

    property var contactDetails: null
    property int maximumLineCount: 2

    signal messageClicked()

    property StatusMessageDetails messageDetails: StatusMessageDetails {
        messageText: notification ? notification.message.messageText : ""
        amISender: false
        sender.id: contactId
        sender.displayName: contactDetails ? contactDetails.displayName : ""
        sender.secondaryName: contactDetails ? contactDetails.localNickname : ""
        sender.trustIndicator: contactDetails ? contactDetails.trustStatus : Constants.trustStatus.unknown
        sender.profileImage {
            width: 40
            height: 40
            name: contactDetails ? contactDetails.displayIcon : ""
            assetSettings.isImage: contactDetails && contactDetails.displayIcon.startsWith("data")
            pubkey: contactId
            colorId: Utils.colorIdForPubkey(contactId)
            colorHash: Utils.getColorHashAsJson(contactId, contactDetails.ensVerified)
        }
    }

    property Component messageSubheaderComponent: null
    property Component messageBadgeComponent: null

    function openProfilePopup() {
        closeActivityCenter()
        Global.openProfilePopup(contactId)
    }

    function updateContactDetails() {
        contactDetails = notification ? Utils.getContactDetailsAsJson(contactId, false) : null
    }

    onContactIdChanged: root.updateContactDetails()

    Connections {
        target: root.store.contactsStore.myContactsModel

        function onItemChanged(pubKey) {
            if (pubKey === root.contactId)
                root.updateContactDetails()
        }
    }

    bodyComponent: MouseArea {
        height: messageRow.implicitHeight
        hoverEnabled: root.messageBadgeComponent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.activityCenterStore.switchTo(notification)
            root.closeActivityCenter()
        }

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
                    tertiaryDetail: Utils.getElidedCompressedPk(sender.id)
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
