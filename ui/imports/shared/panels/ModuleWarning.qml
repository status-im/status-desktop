import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import "../"
import "./"

Item {
    id: root

    enum Type {
        Danger,
        Success
    }

    property bool active: false
    property int type: ModuleWarning.Danger
    property string text: ""
    property alias buttonText: button.text

    signal clicked()
    signal closeClicked()
    signal showStarted()
    signal showFinihsed()
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
        closeButtonMouseArea.clicked(null)
    }

    implicitHeight: root.active ? content.implicitHeight : 0
    visible: implicitHeight > 0

    onActiveChanged: {
        active ? showAnimation.start() : hideAnimation.start()
    }

    NumberAnimation {
        id: showAnimation
        target: root
        property: "implicitHeight"
        from: 0
        to: content.implicitHeight
        duration: 500
        easing.type: Easing.OutCubic
        onStarted: {
            root.showStarted()
        }
        onFinished: {
            root.showFinihsed()
        }
    }

    NumberAnimation {
        id: hideAnimation
        target: root
        property: "implicitHeight"
        to: 0
        from: content.implicitHeight
        duration: 500
        easing.type: Easing.OutCubic
        onStarted: {
            root.hideStarted()
        }
        onFinished: {
            root.hideFinished()
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
        anchors.bottom: parent.bottom
        width: parent.width
        implicitHeight: 32

        readonly property color baseColor: {
            switch (root.type) {
            case ModuleWarning.Danger: return Theme.palette.dangerColor1
            case ModuleWarning.Success: return Theme.palette.successColor1
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            StatusBaseText {
                text: root.text
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.indirectColor1
            }

            Button {
                id: button
                visible: text != ""
                padding: 5
                onClicked: {
                    root.clicked()
                }
                contentItem: Text {
                    text: button.text
                    font.pixelSize: 12
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
