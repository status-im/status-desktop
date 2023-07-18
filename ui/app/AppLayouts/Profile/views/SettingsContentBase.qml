import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property string sectionTitle
    property int contentWidth
    readonly property int contentHeight: root.height - titleRow.height - Style.current.padding

    property alias titleRowLeftComponentLoader: leftLoader
    property alias titleRowComponentLoader: loader
    property list<Item> headerComponents
    property alias bottomHeaderComponents: secondHeaderRow.contentItem
    default property Item content
    property alias titleLayout: titleLayout

    property bool dirty: false
    property bool saveChangesButtonEnabled: false

    signal baseAreaClicked()
    signal saveChangesClicked()
    signal resetChangesClicked()

    function notifyDirty() {
        settingsDirtyToastMessage.notifyDirty();
    }

    QtObject {
        id: d

        readonly property int titleRowHeight: 56
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { root.baseAreaClicked() }
    }

    Component.onCompleted: {
        content.parent = contentWrapper

        if (headerComponents.length) {
            for (let i in headerComponents) {
                headerComponents[i].parent = titleRow
            }
        }
    }

    ColumnLayout {
        id: titleRow
        width: root.contentWidth
        spacing: 0

        RowLayout {
            id: titleLayout
            Layout.preferredWidth: (parent.width - Style.current.padding)
            Layout.preferredHeight: visible ? d.titleRowHeight : 0
            Layout.leftMargin: Style.current.padding
            visible: (root.sectionTitle !== "")

            Loader {
                id: leftLoader
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.sectionTitle
                font.weight: Font.Bold
                font.pixelSize: Constants.settingsSection.mainHeaderFontSize
                color: Theme.palette.directColor1
            }

            Loader {
                id: loader
            }
        }
        Control {
            id: secondHeaderRow
            Layout.fillWidth: true
            visible: !!contentItem
        }
    }

    StatusScrollView {
        id: scrollView
        objectName: "settingsContentBaseScrollView"
        anchors.top: titleRow.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: titleLayout.visible ? Style.current.padding: 0
        padding: 0
        width: root.width
        contentWidth: root.contentWidth
        contentHeight: contentLayout.implicitHeight + Style.current.bigPadding

        Column {
            id: contentLayout
            width: scrollView.availableWidth

            MouseArea {
                onClicked: root.baseAreaClicked()
                width: contentWrapper.implicitWidth
                height: contentWrapper.implicitHeight
                hoverEnabled: true

                Column {
                    id: contentWrapper
                }
            }

            Item {
                // This is a settingsDirtyToastMessage placeholder
                width: settingsDirtyToastMessage.implicitWidth
                height: settingsDirtyToastMessage.active ? settingsDirtyToastMessage.implicitHeight : 0

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    SettingsDirtyToastMessage {
        id: settingsDirtyToastMessage
        anchors.bottom: scrollView.bottom
        anchors.horizontalCenter: scrollView.horizontalCenter
        active: root.dirty
        flickable: scrollView.flickable
        saveChangesButtonEnabled: root.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
    }
}
