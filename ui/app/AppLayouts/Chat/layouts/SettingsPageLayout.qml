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
    property alias title: itemHeader.text
    property Component content


    // optional
    property Component footer
    property bool dirty: false
    property bool editable: false
    property bool headerButtonVisible: false
    property string headerButtonText: ""
    property int headerWidth: 0
    property string previousPageName: ""
    property bool saveChangesButtonEnabled: !!root.contentItem && !!root.contentItem.saveChangesButtonEnabled
    property alias saveChangesText: settingsDirtyToastMessage.saveChangesText
    property alias cancelChangesText: settingsDirtyToastMessage.cancelChangesText
    property alias changesDetectedText: settingsDirtyToastMessage.changesDetectedText
    property alias subTitle: sideTextHeader.text

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

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                StatusBaseText {
                    id: itemHeader

                    Layout.leftMargin: 64

                    color: Theme.palette.directColor1
                    font.pixelSize: 26
                    font.bold: true
                }

                StatusBaseText {
                    id: sideTextHeader

                    Layout.leftMargin: 6
                    Layout.topMargin: 6

                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                }
            }

            StatusButton {
                objectName: "addNewItemActionButton"
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

        Loader {
            visible: !!root.footer
            Layout.fillWidth: true
            sourceComponent: root.footer
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
        flickable: root.dirty ? root.contentItem : null
        saveChangesButtonEnabled: root.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
    }
}
