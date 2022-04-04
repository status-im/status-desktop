import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.13

import utils 1.0
import "../"
import "../panels"
import "../controls"

Popup {
    id: root
    closePolicy: Popup.NoAutoClose
    height: 68
    padding: 0
    margins: 0
    width: Math.max(Math.max(titleText.width, linkStyledText.width)
                    + (toastImage.visible? toastImage.width + rowId.spacing : 0)
                    + rowId.leftPadding + rowId.rightPadding,
                    343)
    x: parent.width - width - Style.current.bigPadding
    y: parent.height - height - Style.current.bigPadding


    readonly property string defaultLinkText: qsTr("View on Etherscan")

    property string uuid: "" // set this if you want to distinct among multiple toasts
    property url source: Style.svg("check-circle")
    property color iconColor: Style.current.primary
    property bool iconRotates: false
    property string title: qsTr("Transaction pending...")
    property string link: "https://etherscan.io/"
    property string linkText: defaultLinkText
    property int dissapearInMs: 4000 /* setting this to -1 makes caller responsible to close it */
    property bool displayCloseButton: true
    property bool displayLink: true

    onOpened: {
        if(dissapearInMs == -1)
            return

        timer.setTimeout(function() {
            root.close()
        }, dissapearInMs);
    }
    onClosed: {
        // Reset props
        source = Style.svg("check-circle")
        iconColor = Style.current.primary
        iconRotates = false
        title = qsTr("Transaction pending...")
        link = "https://etherscan.io/"
        linkText = defaultLinkText
        dissapearInMs = 4000
        displayCloseButton = true
        displayLink = true
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
            color: Style.current.dropShadow
        }
    }

    Row {
        id: rowId
        anchors.fill: parent
        leftPadding: 12
        rightPadding: 12
        topPadding: Style.current.padding
        bottomPadding: Style.current.padding
        spacing: 12

        RoundedIcon {
            id: toastImage
            visible: root.source != ""
            width: 32
            height: 32
            iconHeight: 20
            iconWidth: 20
            color: Utils.setColorAlpha(root.iconColor, 0.1)
            anchors.verticalCenter: parent.verticalCenter
            source: root.source
            iconColor: root.iconColor
            rotates: root.iconRotates
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                id: titleText
                text: root.title
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            StyledText {
                id: linkStyledText
                visible: displayLink
                text: `<a href='${root.link}' style='color:${Style.current.textColorTertiary};text-decoration:none;'>${root.linkText}</a>`
                color: Style.current.textColorTertiary
                textFormat: Text.RichText
                font.pixelSize: 13
                font.weight: Font.Medium
                onLinkActivated: {
                    Global.openLink(root.link)
                    root.close()
                }
            }
        }
    }

    SVGImage {
        id: closeImage
        visible: displayCloseButton
        anchors.right: parent.right
        anchors.top: parent.top
        source: Style.svg("plusSign")
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
        visible: displayCloseButton
        anchors.fill: closeImage
        source: closeImage
        rotation: 45
        color: Style.current.textColor
    }
}
