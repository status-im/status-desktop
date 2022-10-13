import QtQuick 2.3
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0

Badge {
    id: root

    property string communityImage
    property string communityName
    property string communityColor

    property string channelName

    signal communityNameClicked()
    signal channelNameClicked()

    SVGImage {
        id: communityIcon
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter:parent.verticalCenter
        width: 16
        height: 16
        source: Style.svg("communities")
    }

    StatusSmartIdenticon {
        id: identicon
        anchors.left: communityIcon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        name: root.communityName
        asset.width: 16
        asset.height: 16
        asset.color: root.communityColor
        asset.letterSize: width / 2.4
        asset.name: root.communityImage
        asset.isImage: true
    }

    StyledTextEdit {
        id: communityNameText
        width: implicitWidth > 300 ? 300 : implicitWidth
        height: 18
        anchors.left: identicon.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: Utils.getLinkStyle(root.communityName, hoveredLink, root.communityColor)
        readOnly: true
        textFormat: Text.RichText
        clip: true
        color: root.communityColor
        font.pixelSize: 13
        onLinkActivated: root.communityNameClicked()
    }

    SVGImage {
        id: caretImage
        source: Style.svg("show-category")
        width: 16
        height: 16
        visible: root.channelName.length
        anchors.left: communityNameText.right
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: root.communityColor
        }
    }

    StyledTextEdit {
        id: channelNameText
        width: implicitWidth > 300 ? 300 : implicitWidth
        height: 18
        anchors.left: caretImage.right
        anchors.verticalCenter: parent.verticalCenter
        text: Utils.getLinkStyle(root.channelName || name, hoveredLink, root.channelColor)
        readOnly: true
        textFormat: Text.RichText
        clip: true
        color: root.communityColor
        font.pixelSize: 13
        onLinkActivated: root.channelNameClicked()
    }
}
