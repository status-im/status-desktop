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

    ColumnLayout {
        spacing: 2
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true

        StatusMessageHeader {
            Layout.fillWidth: true
            sender: root.messageDetails.sender
            amISender: root.messageDetails.amISender
            messageOriginInfo: root.messageDetails.messageOriginInfo
            tertiaryDetail: sender.isEnsVerified ? "" : root.messageDetails.sender.compressedPubKey
            displayNamePixelSize: Theme.additionalTextSize
            onClicked: root.openProfilePopup()
            clip: true
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
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                font.pixelSize: Theme.additionalTextSize
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
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

        StatusTimeStampLabel {
            id: timestampText
            verticalAlignment: Text.AlignVCenter
            timestamp: root.timestamp
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
