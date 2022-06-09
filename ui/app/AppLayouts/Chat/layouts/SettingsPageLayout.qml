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
    property bool editable: false

    readonly property Item contentItem: contentLoader.item

    signal previousPageClicked
    signal saveChangesClicked
    signal resetChangesClicked

    function reloadContent() {
        contentLoader.active = false
        contentLoader.active = true
    }

    function notifyDirty() {
        cancelChangesButtonAnimation.running = true
        saveChangesButtonAnimation.running = true
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
            Layout.topMargin: 16
            Layout.leftMargin: 24
            Layout.rightMargin: 24

            sourceComponent: root.content
        }

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: buttonsLayout.implicitHeight

            color: Theme.palette.statusToastMessage.backgroundColor
            visible: root.editable

            RowLayout {
                id: buttonsLayout

                anchors.fill: parent
                enabled: root.dirty

                Item {
                    Layout.fillWidth: true
                }

                StatusButton {
                    id: cancelChangesButton

                    text: qsTr("Cancel changes")
                    type: StatusBaseButton.Type.Danger

                    border.color: textColor
                    border.width: 0

                    onClicked: root.resetChangesClicked()

                    NumberAnimation on border.width {
                        id: cancelChangesButtonAnimation
                        from: 0
                        to: 2
                        loops: 2
                        duration: 600

                        onFinished: cancelChangesButton.border.width = 0
                    }
                }

                StatusButton {
                    id: saveChangesButton

                    text: qsTr("Save changes")

                    border.color: textColor
                    border.width: 0

                    onClicked: root.saveChangesClicked()

                    NumberAnimation on border.width {
                        id: saveChangesButtonAnimation
                        from: 0
                        to: 2
                        loops: 2
                        duration: 600

                        onFinished: saveChangesButton.border.width = 0
                    }
                }
            }
        }
    }
}

