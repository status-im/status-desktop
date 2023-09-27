import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1

import shared 1.0
import utils 1.0

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
        Layout.leftMargin: Style.current.padding
        Layout.topMargin: 2

        StatusSmartIdenticon {
            id: profileImage
            name: root.messageDetails.sender.displayName
            asset: root.messageDetails.sender.profileImage.assetSettings
            ringSettings: root.messageDetails.sender.profileImage.ringSettings

            MouseArea {
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
            tertiaryDetail: sender.isEnsVerified ? "" : Utils.getElidedCompressedPk(sender.id)
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
                font.pixelSize: 15
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
