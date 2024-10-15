import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0

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
