import QtQuick 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1

Rectangle {
    id: windowsTitleBar

    property string title: titleText.text

    signal close();
    signal minimised();
    signal maximized();

    implicitHeight: 32
    color: Theme.palette.baseColor5

    Row {
        id: titleLayout
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        spacing: 4

        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            icon: "windows_titlebar/status"
        }

        StatusBaseText {
            id: titleText
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Status")
            color: Theme.palette.directColor1
        }
    }

    Row {
        id: buttonsLayout
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        height: parent.height

        Rectangle {
            width: 48
            height: parent.height

            color: minimizeSensor.containsMouse ? (minimizeSensor.pressed ? Theme.palette.directColor9 : Theme.palette.directColor8)
                                                : "transparent"

            StatusIcon {
                anchors.centerIn: parent
                width: 10
                height: 1
                icon: "windows_titlebar/minimise"
                color: Theme.palette.directColor1
            }

            MouseArea {
                id: minimizeSensor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: windowsTitleBar.minimised()
            }
        }

        Rectangle {
            width: 48
            height: parent.height

            color: maximizeSensor.containsMouse ? (maximizeSensor.pressed ? Theme.palette.directColor9 : Theme.palette.directColor8)
                                                : "transparent"

            StatusIcon {
                anchors.centerIn: parent
                width: 10
                height: 10
                icon: "windows_titlebar/maximize"
                color: Theme.palette.directColor1
            }

            MouseArea {
                id: maximizeSensor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: windowsTitleBar.maximized()
            }
        }

        Rectangle {
            width: 48
            height: parent.height

            color: closeSensor.containsMouse ? (closeSensor.pressed ? "#DB1518" : "#ED4245")
                                                : "transparent"

            StatusIcon {
                anchors.centerIn: parent
                width: 10
                height: 10
                icon: "windows_titlebar/close"
                color: closeSensor.containsMouse ? Theme.palette.white : Theme.palette.directColor1
            }

            MouseArea {
                id: closeSensor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: windowsTitleBar.closed()
            }
        }
    }
}
