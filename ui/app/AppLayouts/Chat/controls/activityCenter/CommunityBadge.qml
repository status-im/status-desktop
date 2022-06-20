import QtQuick 2.3
import QtGraphicalEffects 1.13
import StatusQ.Components 0.1

import utils 1.0
import shared.controls 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0

Item {
    id: communityBadge

    property string image: ""
    property string iconColor: ""
    property bool useLetterIdenticon: !image
    property string communityName: ""
    property string channelName: ""
    property string communityId: ""
    property string name: "channelName"
    property color textColor

    signal communityNameClicked()
    signal channelNameClicked()

    SVGImage {
        id: communityIcon
        width: Style.dp(16)
        height: width
        source: Style.svg("communities")
        anchors.left: parent.left
        anchors.verticalCenter:parent.verticalCenter

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: textColor
        }
    }

    Loader {
        id: communityImageLoader
        active: true
        anchors.left: communityIcon.visible ? communityIcon.right : parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: communityBadge.useLetterIdenticon ? letterIdenticon :imageIcon
    }

    Component {
        id: imageIcon
        RoundedImage {
            source: communityBadge.image
            noMouseArea: true
            noHover: true
            width: Style.dp(16)
            height: width
        }
    }

    Component {
        id: letterIdenticon
        StatusLetterIdenticon {
            width: Style.dp(16)
            height: width
            letterSize: Style.dp(12)
            name: communityBadge.communityName
            color: communityBadge.iconColor
        }
    }

    StyledTextEdit {
        id: communityName
        text: Utils.getLinkStyle(communityBadge.communityName, hoveredLink, textColor)
        height: Style.dp(18)
        readOnly: true
        textFormat: Text.RichText
        width: implicitWidth > Style.dp(300) ? Style.dp(300) : implicitWidth
        clip: true
        anchors.left: communityImageLoader.right
        anchors.leftMargin: Style.dp(4)
        color: textColor
        font.pixelSize: Style.current.additionalTextSize
        anchors.verticalCenter: parent.verticalCenter
        onLinkActivated: communityNameClicked()
    }

    SVGImage {
        id: caretImage
        source: Style.svg("show-category")
        width: Style.dp(16)
        height: width
        anchors.left: communityName.right
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: textColor
        }
    }

    StyledTextEdit {
        id: channelName
        text: Utils.getLinkStyle(communityBadge.channelName || name, hoveredLink, textColor)
        height: Style.dp(18)
        readOnly: true
        textFormat: Text.RichText
        width: implicitWidth > 300 ? 300 : implicitWidth
        clip: true
        anchors.left: caretImage.right
        color: textColor
        font.pixelSize: Style.current.additionalTextSize
        anchors.verticalCenter: parent.verticalCenter
        onLinkActivated: channelNameClicked()
    }
}
