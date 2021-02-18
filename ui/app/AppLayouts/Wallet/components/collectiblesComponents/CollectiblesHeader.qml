import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Rectangle {
    property url collectibleIconSource: "../../../../img/collectibles/CryptoKitties.png"
    property string collectibleName: "CryptoKitties"
    property bool isLoading: true
    property bool hovered: false
    property var toggleCollectible: function () {}
    property int collectiblesQty: 6

    id: collectibleHeader
    height: 64
    width: parent.width
    color: hovered ? Style.current.backgroundHover : Style.current.transparent
    border.width: 0
    radius: Style.current.radius

    Image {
        id: collectibleIconImage
        source: collectibleHeader.collectibleIconSource
        width: 40
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: collectibleName
        text: collectibleHeader.collectibleName
        anchors.left: collectibleIconImage.right
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 17
    }

    StyledText {
        visible: collectiblesQty >= Constants.maxTokens
        //% "Maximum number of collectibles to display reached"
        text: qsTrId("maximum-number-of-collectibles-to-display-reached")
        font.pixelSize: 17
        color: Style.current.secondaryText
        anchors.left: collectibleName.right
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter

    }

    Loader {
        active: true
        sourceComponent: collectibleHeader.isLoading ? loadingComponent : handleComponent
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    Component {
        id: loadingComponent

        LoadingImage {}
    }

    Component {
        id: handleComponent

        Item {
            id: element1
            width: childrenRect.width
            height: numberCollectibleText.height

            StyledText {
                id: numberCollectibleText
                color: Style.current.secondaryText
                text: !!error ? "-" : collectibleHeader.collectiblesQty
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            SVGImage {
                id: caretImg
                anchors.verticalCenter: parent.verticalCenter
                source: "../../../../img/caret.svg"
                width: 11
                anchors.left: numberCollectibleText.right
                anchors.leftMargin: Style.current.padding
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: caretImg
                source: caretImg
                color: Style.current.black
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
