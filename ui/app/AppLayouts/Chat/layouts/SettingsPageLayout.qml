import QtQuick 2.14
import QtQuick.Layouts 1.14

import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    // required
    property string title
    property Component content

    // optional
    property string previousPage
    property bool dirty: false

    readonly property Item contentItem: contentLoader.item

    signal previousPageClicked
    signal saveChangesClicked
    signal resetChangesClicked

    function reloadContent() {
        contentLoader.active = false
        contentLoader.active = true
    }

    function notifyDirty() {
        toastAnimation.running = true
        saveChangesButton.forceActiveFocus()
    }

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors.fill: parent

        spacing: 16

        Item {
            implicitHeight: 32

            StatusBaseText {
                visible: root.previousPage
                text: "<- " + root.previousPage
                color: Theme.palette.primaryColor1
                font.pixelSize: 15

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.previousPageClicked()
                }
            }
        }

        StatusBaseText {
            Layout.leftMargin: 32

            text: root.title
            color: Theme.palette.directColor1
            font.pixelSize: 26
            font.bold: true
        }

        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: root.content
        }
    }

    Rectangle {
        id: toastMessage

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 16
        }

        height: toastContent.height + 16
        width: toastContent.width + 16

        opacity: root.dirty ? 1 : 0
        color: Theme.palette.statusToastMessage.backgroundColor
        radius: 8
        border.color: Theme.palette.dangerColor2
        border.width: 2
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: Theme.palette.dangerColor2
            spread: 0.1
        }

        NumberAnimation on border.width {
            id: toastAnimation
            from: 0
            to: 4
            loops: 2
            duration: 600

            onFinished: toastMessage.border.width = 2
        }

        RowLayout {
            id: toastContent

            x: 8
            y: 8

            StatusBaseText {
                text: qsTr("Changes detected!")
                color: Theme.palette.directColor1
            }

            StatusButton {
                text: qsTr("Cancel")
                type: StatusBaseButton.Type.Danger
                onClicked: root.resetChangesClicked()
            }

            StatusButton {
                id: saveChangesButton

                text: qsTr("Save changes")
                onClicked: root.saveChangesClicked()
            }
        }

        Behavior on opacity {
            NumberAnimation {}
        }
    }
}

