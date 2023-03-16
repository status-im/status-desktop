import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0

StatusDialog {
    id: root

    enum Source {
        Mobile,
        Desktop
    }

    title: qsTr("How to get a sync code on...")
    padding: 40
    footer: null
    ColumnLayout {
        anchors.fill: parent
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
            }

            GetSyncCodeDesktopInstructions {
                id: desktopSync
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignHCenter
            }
        }

    }

}
