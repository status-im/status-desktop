import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils as CoreUtils
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Components.private

import  AppLayouts.ActivityCenter.controls

import shared
import utils

RowLayout {
    id: root

    property int maximumLineCount: 5
    property alias contentHeaderAreaText: contentHeaderArea.text

    property StatusMessageDetails messageDetails: StatusMessageDetails {}

    signal openProfilePopup()

    spacing: 8

    ColumnLayout {
        spacing: 2
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true

        NotificationBaseHeaderRow {
            Layout.fillWidth: true

            property bool amISender: root.messageDetails.amISender
            property var sender: root.messageDetails.sender
            property string messageOriginInfo: root.messageDetails.messageOriginInfo

            primaryText: amISender ? qsTr("You") : CoreUtils.Emoji.parse(sender.displayName)
            primaryTextClickable: true
            primarySideText: messageOriginInfo
            iconsRowComponent: !amISender ? iconsRow : undefined
            secondaryText: !amISender ? sender.secondaryName : ""
            tertiaryText: !amISender &&
                          messageOriginInfo === "" &&
                          sender.isEnsVerified ?  "" : sender.compressedPubKey

            onPrimaryTextClicked: root.openProfilePopup()

            Component {
                id: iconsRow
                StatusContactVerificationIcons {
                    isContact: root.messageDetails.sender.isContact
                    trustIndicator: root.messageDetails.sender.trustIndicator
                }
            }
        }

        StatusBaseText {
            id: contentHeaderArea
            Layout.fillWidth: true
            Layout.preferredHeight: !text ? 0 : implicitHeight
            maximumLineCount: root.maximumLineCount
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            font.pixelSize: Theme.additionalTextSize
            font.italic: true
        }

        StatusBaseText {
            id: contentArea
            Layout.fillWidth: true
            Layout.preferredHeight: !text ? 0 : implicitHeight
            text: root.messageDetails.messageText
            maximumLineCount: root.maximumLineCount
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            font.pixelSize: Theme.additionalTextSize
        }

        Loader {
            active: root.messageDetails.contentType === Constants.messageContentType.imageType
            visible: active
            Layout.fillWidth: true
            sourceComponent: StatusMessageImageAlbum {
                width: parent.width
                album: root.messageDetails.albumCount > 0 ? root.messageDetails.album : [root.messageDetails.messageContent]
                albumCount: root.messageDetails.albumCount || 1
                imageWidth: 56
                loadingComponentHeight: 56
                shapeType: StatusImageMessage.ShapeType.ROUNDED
            }
        }
    }
}
