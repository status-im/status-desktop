import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme

import utils
import shared.controls

ColumnLayout {
    id: root

    enum Purpose {
        AppSync,
        KeypairSync
    }

    enum Type {
        QRCode,
        EncryptedKey
    }

    property int purpose: SyncingCodeInstructions.Purpose.AppSync
    property int type: SyncingCodeInstructions.Type.QRCode

    spacing: Theme.xlPadding

    StatusSwitchTabBar {
        id: switchTabBar
        Layout.fillWidth: true
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
        Layout.minimumWidth: 400
        currentIndex: 0

        StatusSwitchTabButton {
            text: qsTr("Mobile")
        }

        StatusSwitchTabButton {
            text: qsTr("Desktop")
        }
    }

    StackLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(mobileSync.implicitHeight, desktopSync.implicitHeight)
        currentIndex: switchTabBar.currentIndex

        GetSyncCodeMobileInstructions {
            id: mobileSync
            Layout.alignment: Qt.AlignHCenter

            purpose: root.purpose
            type: root.type
        }

        GetSyncCodeDesktopInstructions {
            id: desktopSync
            Layout.alignment: Qt.AlignHCenter

            purpose: root.purpose
            type: root.type
        }
    }
}
