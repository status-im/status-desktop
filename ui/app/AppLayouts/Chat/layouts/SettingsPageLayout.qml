import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

Item {
    id: root

    // required
    property string title
    property Component content

    // optional
    property bool dirty: false
    property bool editable: false
    property bool headerButtonVisible: false
    property string headerButtonText: ""
    property int headerWidth: 0
    property string previousPageName: ""

    readonly property Item contentItem: contentLoader.item
    readonly property size settingsDirtyToastMessageImplicitSize: 
        Qt.size(settingsDirtyToastMessage.implicitWidth,
                settingsDirtyToastMessage.implicitHeight + settingsDirtyToastMessage.anchors.bottomMargin)

    signal saveChangesClicked
    signal resetChangesClicked
    signal headerButtonClicked

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

        RowLayout {
            Layout.maximumWidth: root.headerWidth === 0 ? parent.width : (root.headerWidth + itemHeader.Layout.leftMargin)
            Layout.preferredHeight: 56

            StatusBaseText {
                id: itemHeader
                Layout.leftMargin: 64
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: root.title
                color: Theme.palette.directColor1
                font.pixelSize: 26
                font.bold: true
            }

            StatusButton {
                visible: root.headerButtonVisible
                text: root.headerButtonText
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.headerButtonClicked()
            }
        }

        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 16
            Layout.leftMargin: 64
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
        saveChangesButtonEnabled: !!root.contentItem && !!root.contentItem.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
    }
}
