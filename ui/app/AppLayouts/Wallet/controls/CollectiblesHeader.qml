import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.panels 1.0

Rectangle {
    property url collectibleIconSource: "CryptoKitties"
    property string collectibleName: "CryptoKitties"
    property bool isLoading: true
    property bool hovered: false
    property var toggleCollectible: function () {}
    property int collectiblesQty: 6

    id: collectibleHeader
    height: 64
    width: parent.width
    color: hovered ? Theme.palette.backgroundHover : Theme.palette.transparent
    border.width: 0
    radius: Theme.radius

    Image {
        id: collectibleIconImage
        source: collectibleHeader.collectibleIconSource
        width: 40
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        cache: false
    }

    StyledText {
        id: collectibleName
        text: collectibleHeader.collectibleName
        anchors.left: collectibleIconImage.right
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 17
    }

    StyledText {
        visible: collectiblesQty >= Constants.maxTokens
        text: qsTr("Maximum number of collectibles to display reached")
        font.pixelSize: 17
        color: Theme.palette.secondaryText
        anchors.left: collectibleName.right
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter

    }

    Loader {
        active: true
        sourceComponent: collectibleHeader.isLoading ? loadingComponent : handleComponent
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    Component {
        id: loadingComponent

        StatusLoadingIndicator {}
    }

    Component {
        id: handleComponent

        Item {
            id: element1
            width: childrenRect.width
            height: numberCollectibleText.height

            StyledText {
                id: numberCollectibleText
                color: Theme.palette.secondaryText
                text: !!error ? "-" : collectibleHeader.collectiblesQty
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            SVGImage {
                id: caretImg
                anchors.verticalCenter: parent.verticalCenter
                source: Theme.svg("caret")
                width: 11
                anchors.left: numberCollectibleText.right
                anchors.leftMargin: Theme.padding
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: caretImg
                source: caretImg
                color: Theme.palette.black
            }
        }
    }

    MouseArea {
        enabled: !collectibleHeader.isLoading
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            collectibleHeader.hovered = true
        }
        onExited: {
            collectibleHeader.hovered = false
        }
        onClicked: {
            collectibleHeader.toggleCollectible()
        }
    }
}
