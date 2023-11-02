import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root

    enum Type {
        Danger,
        Warning,
        Success
    }

    property bool active: false
    property int type: ModuleWarning.Danger
    property int progressValue: -1 // 0..100, -1 not visible
    property string text: ""
    property alias buttonText: button.text
    property alias closeBtnVisible: closeImg.visible
    property string iconName
    property bool delay: true

    signal clicked()
    signal closeClicked()
    signal showStarted()
    signal showFinished()
    signal hideStarted()
    signal hideFinished()

    function show() {
        hideTimer.stop()
        active = true;
    }

    function showFor(duration = 5000) {
        show();
        hide(duration);
    }

    function hide(timeout = 0) {
        hideTimer.interval = timeout
        hideTimer.start()
    }

    function close() {
        root.closeClicked()
    }

    signal linkActivated(string link)

    onActiveChanged: {
        if (root.active && root.delay) {
            showTimer.start();
        }
    }

    NumberAnimation {
        id: showAnimation
        target: root
        running: (root.active && !root.delay)
        property: "implicitHeight"
        from: 0
        to: 32
        duration: 500
        easing.type: Easing.OutCubic
        onStarted: {
            root.visible = true;
            root.showStarted()
        }
        onFinished: {
            root.showFinished()
        }
    }

    NumberAnimation {
        id: hideAnimation
        running: !root.active
        target: root
        property: "implicitHeight"
        from: 32
        to: 0
        duration: 500
        easing.type: Easing.OutCubic
        onStarted: {
            root.hideStarted()
            root.visible = false;
        }
        onFinished: {
            root.hideFinished()
        }
    }

    Timer {
        id: showTimer
        interval: 3000
        onTriggered: {
            if (root.active) {
                showAnimation.start();
            }
        }
    }

    Timer {
        id: hideTimer
        repeat: false
        running: false
        onTriggered: {
            root.active = false
        }
    }

    Rectangle {
        id: content
        anchors.fill: parent

        readonly property color baseColor: {
            switch (root.type) {
            case ModuleWarning.Danger: return Theme.palette.dangerColor1
            case ModuleWarning.Success: return Theme.palette.successColor1
            case ModuleWarning.Warning: return Theme.palette.warningColor1
            default: return Theme.palette.baseColor1
            }
        }

        color: baseColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        RowLayout {
            id: layout

            spacing: 12
            anchors.centerIn: parent

            StatusRoundIcon {
                Layout.preferredHeight: 16
                Layout.preferredWidth: 16
                Layout.rightMargin: -8
                visible: !!root.iconName
                asset.name: root.iconName
                asset.bgColor: Theme.palette.indirectColor1
                asset.color: content.baseColor
            }

            StatusBaseText {
                text: root.text
                font.pixelSize: 13
                font.weight: Font.Medium
                color: Theme.palette.indirectColor1
                linkColor: color
                onLinkActivated: root.linkActivated(link)
                HoverHandler {
                    id: handler1
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: handler1.hovered && parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Button {
                id: button
                visible: text != ""
                focusPolicy: Qt.NoFocus
                padding: 5
                onClicked: {
                    root.clicked()
                }
                contentItem: StatusBaseText {
                    text: button.text
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: Style.current.baseFont.name
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.palette.indirectColor1
                }
                background: Rectangle {
                    radius: 4
                    border.width: 1
                    border.color: Theme.palette.indirectColor3
                    color: Theme.palette.getColor("white", button.hovered ? 0.4 : 0.1)
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: progressBar.left
            anchors.rightMargin: Style.current.halfPadding
            text: qsTr("%1%").arg(progressBar.value)
            visible: progressBar.visible
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.white
        }

        ProgressBar {
            id: progressBar
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: closeImg.left
            anchors.rightMargin: Style.current.bigPadding
            from: 0
            to: 100
            visible: root.progressValue > -1
            value: root.progressValue
            background: Rectangle {
                implicitWidth: 64
                implicitHeight: 8
                radius: 8
                color: "transparent"
                border.width: 1
                border.color: Theme.palette.white
            }
            contentItem: Rectangle {
                width: progressBar.width*progressBar.position
                implicitHeight: 8
                radius: 8
                color: Theme.palette.white
            }
        }

        StatusIcon {
            id: closeImg
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 18
            height: 20
            width: 20
            icon: "close-circle"
            color: Theme.palette.indirectColor1
            opacity: closeButtonMouseArea.containsMouse ? 1 : 0.7

            MouseArea {
                id: closeButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.closeClicked()
                }
            }
        }
    }
}
