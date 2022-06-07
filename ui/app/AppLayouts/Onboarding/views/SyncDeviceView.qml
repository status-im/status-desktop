import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.panels 1.0

import "../popups"
import "../controls"
import "sync"

import utils 1.0

OnboardingBasePage {
    id: root

    signal userValidated()

    QtObject {
        id: d
        readonly property int listItemHeight: 40
    }

    Column {
        id: layout

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 565

        StatusBaseText {
            id: headlineText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            text: qsTr("Sync to other device")
        }

        Item {
            width: parent.width
            implicitHeight: 24
        }

        StatusSwitchTabBar {
            id: switchTabBar
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: 1

            StatusSwitchTabButton {
                text: qsTr("From mobile")
                enabled: false
            }

            StatusSwitchTabButton {
                text: qsTr("From desktop")
            }
        }

        Item {
            width: parent.width
            implicitHeight: 71
        }

        StackLayout {
            width: parent.width

            implicitWidth: Math.max(mobileSync.implicitWidth, desktopSync.implicitWidth)
            implicitHeight: Math.max(mobileSync.implicitHeight, desktopSync.implicitHeight)
            currentIndex: switchTabBar.currentIndex

            SyncDeviceFromMobile {
                id: mobileSync
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
            }

            SyncDeviceFromDesktop {
                id: desktopSync
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

}
