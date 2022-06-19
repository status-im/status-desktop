import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import shared.controls.chat 1.0

import "../../controls"
import "../../stores"

ColumnLayout {
    id: root

    property DevicesStore devicesStore
    property ProfileStore profileStore

    property bool syncingInProgress: false
    property bool syncingFailed: false
    property bool syncingSuccess: false

    spacing: 0

    QtObject {
        id: d
        readonly property int deviceDelegateWidth: 220
    }

    UserImage {
        id: userImage
        Layout.alignment: Qt.AlignHCenter
        name: root.profileStore.displayName
        pubkey: root.profileStore.pubkey
        image: root.profileStore.icon
        interactive: false
        imageWidth: 80
        imageHeight: 80
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: 8
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.directColor1
        font.weight: Font.Bold
        font.pixelSize: 22
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        text: root.profileStore.displayName
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: 31
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 17
        color: Theme.palette.directColor1
        text: {
            if (root.syncingInProgress)
                return qsTr("Device found!");
            if (root.syncingSuccess)
                return qsTr("Device synced!");
            if (root.syncingFailed)
                return qsTr("Device failed to sync");
            return "";
        }
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.bottomMargin: 25
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        color: Theme.palette.baseColor1
        text: {
            if (root.syncingInProgress)
                return qsTr("Syncing your profile and settings preferences");
            if (root.syncingSuccess)
                return qsTr("Your devices are now in sync");
            if (root.syncingFailed)
                return qsTr("Please try again.");
            return "";
        }
    }

    SyncDeviceDelegate {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: d.deviceDelegateWidth
        subTitle: loadingFailed ? qsTr("Device") : qsTr("Incoming device")
        enabled: false
        loading: root.syncingInProgress
        loadingFailed: root.syncingFailed
    }

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 25
        Layout.bottomMargin: 25
        implicitHeight: 1
        implicitWidth: d.deviceDelegateWidth
        color: Theme.palette.baseColor4
    }

    ListView {
        id: listView
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true

        implicitWidth: d.deviceDelegateWidth
        implicitHeight: contentHeight

        model: root.devicesStore.devicesModel
        spacing: 4
        clip: true

        delegate: SyncDeviceDelegate {
            width: ListView.view.width
            enabled: false
        }
    }

}
