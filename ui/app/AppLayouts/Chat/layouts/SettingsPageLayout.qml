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
    property int headerWidth: d.defaultContentWidth
    property string previousPageName: ""
    property bool saveChangesButtonEnabled: !!root.contentItem && !!root.contentItem.saveChangesButtonEnabled
    property alias primaryHeaderButton: primaryHeaderBtn
    property alias secondaryHeaderButton: secondaryHeaderBtn
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
    signal primaryHeaderButtonClicked
    signal secondaryHeaderButtonClicked

    QtObject {
        id: d

        readonly property int leftMargin: 64
        readonly property int defaultContentWidth: 560
    }

    function reloadContent() {
        contentLoader.active = false
        contentLoader.active = true
    }

    function notifyDirty() {
        settingsDirtyToastMessage.notifyDirty()
    }

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.bottomMargin: 24
        spacing: 16

        RowLayout {
            Layout.leftMargin: d.leftMargin
            Layout.maximumWidth: root.headerWidth
            Layout.maximumHeight: 44

            spacing: 9

            RowLayout {
                Layout.alignment: Qt.AlignVCenter

                StatusBaseText {
                    id: itemHeader

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

            // Filler
            Item {
                Layout.fillWidth: true
            }

            StatusButton {
                id: secondaryHeaderBtn

                Layout.fillHeight: true

                objectName: "secondaryHeaderButton"
                visible: false

                onClicked: root.secondaryHeaderButtonClicked()
            }

            StatusButton {
                id: primaryHeaderBtn

                Layout.fillHeight: true

                objectName: "primaryHeaderButton"
                visible: false

                onClicked: root.primaryHeaderButtonClicked()
            }
        }

        Loader {
            id: contentLoader

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: d.leftMargin
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
