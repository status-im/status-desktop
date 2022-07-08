import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.popups 1.0

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
    readonly property size settingsDirtyToastMessageImplicitSize: 
        Qt.size(settingsDirtyToastMessage.implicitWidth,
                settingsDirtyToastMessage.implicitHeight + settingsDirtyToastMessage.anchors.bottomMargin)

    signal previousPageClicked
    signal saveChangesClicked
    signal resetChangesClicked

    function reloadContent() {
        contentLoader.active = false
        contentLoader.active = true
    }

    function notifyDirty() {
        settingsDirtyToastMessage.notifyDirty()
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
            Layout.leftMargin: 24
            Layout.rightMargin: 24

            sourceComponent: root.content
        }
    }

    SettingsDirtyToastMessage {
        id: settingsDirtyToastMessage
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 16
        }
        active: root.dirty
        flickable: root.contentItem
        saveChangesButtonEnabled: root.contentItem && root.contentItem.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
    }
}

