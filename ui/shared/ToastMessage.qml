import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.13
import "../imports"

Popup {
    property url source: "../app/img/check-circle.svg"
    property string title: "Transaction pending..."
    property string linkText: qsTr("View on Etherscan")

    id: root
    height: 68
    padding: 0
    margins: 0
    width: 343
    x: parent.width - width - Style.current.bigPadding
    y: parent.height - height - Style.current.bigPadding

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background

        layer.enabled: true
        layer.effect: DropShadow{
            width: container.width
            height: container.height
            x: container.x
            y: container.y + 10
            visible: container.visible
            source: container
            horizontalOffset: 0
            verticalOffset: 2
            radius: 10
            samples: 15
            color: "#22000000"
        }
    }

    RoundedIcon {
        id: toastImage
        width: 32
        height: 32
        iconHeight: 20
        iconWidth: 20
        color: Style.current.secondaryBackground
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        source: root.source
        anchors.leftMargin: 12
    }

    StyledText {
        id: titleText
        text: root.title
        anchors.left: toastImage.right
        anchors.top: parent.top
        font.pixelSize: 13
        font.weight: Font.Medium
        anchors.topMargin: Style.current.padding
        anchors.leftMargin: 12
    }

    StyledText {
        text: root.linkText
        color: Style.current.textColorTertiary
        anchors.left: toastImage.right
        anchors.top: titleText.bottom
        font.pixelSize: 13
        font.weight: Font.Medium
        anchors.leftMargin: 12
    }

    SVGImage {
        id: closeImage
        anchors.right: parent.right
        anchors.top: parent.top
        source: "../app/img/plusSign.svg"
        anchors.topMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        width: 9
        height: 9
        rotation: 45

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.close()
            }
        }
    }
    ColorOverlay {
        anchors.fill: closeImage
        source: closeImage
        rotation: 45
        color: Style.current.textColor
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#4c4e50";formeditorZoom:1.5;height:68;width:343}
}
##^##*/
