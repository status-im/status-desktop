import QtQuick 2.1
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0

Rectangle {
    property bool downloadComplete: false
    property bool isCanceled: false
    property bool isPaused: false
    property bool hovered: false
    // use this to place the newest downloads first
    property int reversedIndex: listView.count - 1 - index
    property string primaryText: ""
    property string downloadText: ""

    signal optionsButtonClicked(var xVal)
    signal itemClicked()

    id: root
    width: Style.dp(272)
    height: Style.dp(40)
    border.width: 0
    color: hovered ? Style.current.backgroundHover : Style.current.transparent
    radius: Style.current.radius

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
           root.hovered = true
        }
        onExited: {
            root.hovered = false
        }
        onClicked: {
            itemClicked()
        }
    }

    Loader {
        id: iconLoader
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        active: root.visible
        sourceComponent: {
            if (downloadComplete || isPaused || isCanceled) {
                return fileImageComponent
            }
            return loadingImageComponent
        }

        Component {
            id: loadingImageComponent
            StatusLoadingIndicator {}
        }
        Component {
            id: fileImageComponent
            SVGImage {
                source: Style.svg("browser/file")
                width: Style.dp(24)
                height: Style.dp(24)
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: downloadComplete ? Style.current.transparent : Style.current.darkGrey
                }
            }
        }
    }

    StyledText {
        id: filenameText
        text: primaryText
        elide: Text.ElideRight
        anchors.left: iconLoader.right
        anchors.right: optionsBtn.left
        anchors.top:  downloadComplete ? undefined : parent.top
        anchors.verticalCenter: downloadComplete ? parent.verticalCenter : undefined
        minimumPixelSize: Style.dp(13)
        anchors.leftMargin: Style.current.smallPadding
        anchors.topMargin: Style.dp(2)
    }

    StyledText {
        id: progressText
        visible:  !downloadComplete
        color: Style.current.secondaryText
        text: downloadText
        elide: Text.ElideRight
        anchors.left: iconLoader.right
        anchors.right: optionsBtn.left
        anchors.bottom: parent.bottom
        minimumPixelSize: Style.dp(13)
        anchors.leftMargin: Style.current.smallPadding
        anchors.bottomMargin: Style.dp(2)
    }

    StatusFlatRoundButton {
        width: Style.dp(32)
        height: Style.dp(32)
        id: optionsBtn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        icon.name: "more"
        type: StatusFlatRoundButton.Type.Tertiary
        onClicked: optionsButtonClicked(optionsBtn.x)
    }
}

