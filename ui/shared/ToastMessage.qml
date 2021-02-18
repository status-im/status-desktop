import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.13
import "../imports"
import "."

Popup {
    property url source: "../app/img/check-circle.svg"
    property color iconColor: Style.current.primary
    property bool iconRotates: false
    property string title: "Transaction pending..."
    //% "View on Etherscan"
    readonly property string defaultLinkText: qsTrId("view-on-etherscan")
    property string link: "https://etherscan.io/"
    property string linkText: defaultLinkText

    id: root
    closePolicy: Popup.NoAutoClose
    height: 68
    padding: 0
    margins: 0
    width: Math.max(Math.max(titleText.width, linkText.width) + toastImage.width + 12 * 4, 343)
    x: parent.width - width - Style.current.bigPadding
    y: parent.height - height - Style.current.bigPadding

    onOpened: {
        timer.setTimeout(function() {
            root.close()
        }, 4000);
    }
    onClosed: {
        // Reset props
        iconColor = Style.current.primary
        iconRotates = false
        root.linkText = defaultLinkText
    }

    Timer {
        id: timer
    }

    background: Rectangle {
        id: container
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
        color: Utils.setColorAlpha(root.iconColor, 0.1)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        source: root.source
        anchors.leftMargin: 12
        iconColor: root.iconColor
        rotates: root.iconRotates
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
        id: linkText
        //% "<a href='%1' style='color:%2;text-decoration:none;'>%3</a>"
        text: qsTrId("-a-href---1--style--color--2-text-decoration-none----3--a-")
            .arg(Style.current.textColorTertiary)
            .arg(root.link)
            .arg(root.linkText)
        color: Style.current.textColorTertiary
        textFormat: Text.RichText
        anchors.left: toastImage.right
        anchors.top: titleText.bottom
        font.pixelSize: 13
        font.weight: Font.Medium
        anchors.leftMargin: 12
        onLinkActivated: {
            appMain.openLink(root.link)
            root.close()
        }
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
