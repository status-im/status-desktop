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
    readonly property int contentHeight: (root.height - d.topHeaderHeight - d.titleRowHeight)

    property alias titleRowComponentLoader: loader
    property list<Item> headerComponents
    default property Item content

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

        readonly property int topHeaderHeight: 56
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

    RowLayout {
        id: titleRow
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        width: visible ? root.contentWidth - Style.current.padding : 0
        height: visible ? d.titleRowHeight : 0
        visible: root.sectionTitle !== ""

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

    StatusScrollView {
        id: scrollView
        objectName: "settingsContentBaseScrollView"
        anchors.top: titleRow.visible ? titleRow.bottom : parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.bigPadding
        padding: 0
        width: root.contentWidth

        Column {
            id: contentLayout
            width: scrollView.availableWidth

            MouseArea {
                onClicked: root.baseAreaClicked()
                width: contentWrapper.implicitWidth
                height: contentWrapper.implicitHeight

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
        flickable: scrollView
        saveChangesButtonEnabled: root.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
    }
}
