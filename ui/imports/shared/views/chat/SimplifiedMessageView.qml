import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils as CoreUtils
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Components.private

import shared
import utils

RowLayout {
    id: root

    property double timestamp: 0
    property int maximumLineCount: 5

    property Component messageSubheaderComponent: null
    property Component messageBadgeComponent: null

    property StatusMessageDetails messageDetails: StatusMessageDetails {}

    signal openProfilePopup()

    spacing: 8

    Item {
        Layout.preferredWidth: root.messageDetails.sender.profileImage.assetSettings.width
        Layout.preferredHeight: profileImage.height
        Layout.alignment: Qt.AlignTop
        Layout.leftMargin: Theme.padding
        Layout.topMargin: 2

        StatusSmartIdenticon {
            id: profileImage
            name: root.messageDetails.sender.displayName
            asset: root.messageDetails.sender.profileImage.assetSettings
            ringSettings: root.messageDetails.sender.profileImage.ringSettings

            StatusMouseArea {
                anchors.fill: parent
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
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
            tertiaryDetail: sender.isEnsVerified ? "" : root.messageDetails.sender.compressedPubKey
            timestamp: root.timestamp
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
                text: root.messageDetails.messageText
                maximumLineCount: root.maximumLineCount
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                font.pixelSize: Theme.primaryTextFontSize
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: !root.messageBadgeComponent
            }

            Loader {
                sourceComponent: root.messageBadgeComponent
                Layout.alignment: Qt.AlignVCenter
                Layout.fillHeight: true
            }

            Item {
                Layout.fillWidth: !!root.messageBadgeComponent
            }
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
