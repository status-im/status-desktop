import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    enum Type {
        AppSync,
        KeypairSync
    }

    property int type: SyncingCodeInstructions.Type.AppSync

    spacing: 0

    StatusSwitchTabBar {
        id: switchTabBar
        Layout.fillWidth: true
        Layout.minimumWidth: 400
        currentIndex: 0

        StatusSwitchTabButton {
            text: qsTr("Mobile")
        }

        StatusSwitchTabButton {
            text: qsTr("Desktop")
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: 41
    }

    StackLayout {
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: Math.max(mobileSync.implicitWidth, desktopSync.implicitWidth)
        implicitHeight: Math.max(mobileSync.implicitHeight, desktopSync.implicitHeight)
        currentIndex: switchTabBar.currentIndex

        GetSyncCodeMobileInstructions {
            id: mobileSync
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter

            type: root.type
        }

        GetSyncCodeDesktopInstructions {
            id: desktopSync
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter

            type: root.type
        }
    }
}
