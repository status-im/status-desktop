import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0
import shared.controls.chat 1.0
import utils 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

    property alias devicesModel: sfpModel.sourceModel
    property string userDisplayName
    property string userColorId
    property string userColorHash
    property string userPublicKey
    property string userImage
    property string installationId
    property string installationName
    property string installationDeviceType

    property int localPairingState: Constants.LocalPairingState.Idle
    property string localPairingError

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        readonly property int deviceDelegateWidth: 220
        readonly property bool pairingFailed: root.localPairingState === Constants.LocalPairingState.Error
        readonly property bool pairingSuccess: root.localPairingState === Constants.LocalPairingState.Finished
        readonly property bool pairingInProgress: !d.pairingFailed && !d.pairingSuccess
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 0

        // This is used in the profile section. The user's pubkey is available
        // so we can calculate the hash and colorId
        Loader {
            id: profileSectionUserImage
            active: root.userPublicKey != ""
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: UserImage {
                name: root.userDisplayName
                pubkey: root.userPublicKey
                image: root.userImage
                interactive: false
                imageWidth: 80
                imageHeight: 80
            }
        }

        // This is used in the onboarding once a sync code is received. The
        // user's pubkey is unknown, but we have the multiaccount information
        // available (from the plaintext accounts db), so we use the colorHash
        // and colorId directly
        Loader {
            id: colorUserImage
            active: root.userPublicKey == ""
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: UserImage {
                name: root.userDisplayName
                colorId: root.userColorId
                colorHash: root.userColorHash
                image: root.userImage
                interactive: false
                imageWidth: 80
                imageHeight: 80
                loading: name === ""
            }
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
            text: root.userDisplayName
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: 31
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 17
            color: d.pairingFailed ? Theme.palette.dangerColor1 : Theme.palette.directColor1
            text: {
                if (d.pairingInProgress)
                    return qsTr("Device found!");
                if (d.pairingSuccess)
                    return qsTr("Device synced!");
                if (d.pairingFailed)
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
            visible: !!text
            text: {
                if (d.pairingInProgress)
                    return qsTr("Syncing your profile and settings preferences");
                if (d.pairingSuccess)
                    return qsTr("Your devices are now in sync");
                return "";
            }
        }

        StatusSyncDeviceDelegate {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: d.deviceDelegateWidth
            visible: !d.pairingFailed
            subTitle: d.pairingInProgress ? qsTr("Syncing with device")
                                          : qsTr("Synced device")
            enabled: false
            loading: d.pairingInProgress
            loadingSubTitle: false
            deviceName: root.installationName
            deviceType: root.installationDeviceType
            isCurrentDevice: false
            showOnlineBadge: false
        }

        ErrorDetails {
            Layout.fillWidth: true
            Layout.leftMargin: 60
            Layout.rightMargin: 60
            Layout.preferredWidth: 360
            Layout.topMargin: 12
            visible: d.pairingFailed
            title: qsTr("Failed to sync devices")
            details: root.localPairingError
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 25
            Layout.bottomMargin: 25
            implicitHeight: 1
            implicitWidth: d.deviceDelegateWidth
            color: Theme.palette.baseColor4
            opacity: listView.count ? 1 : 0
        }

        StatusListView {
            id: listView

            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true

            implicitWidth: contentWidth
            implicitHeight: contentHeight
            contentWidth: d.deviceDelegateWidth

            spacing: 4
            clip: true

            model: SortFilterProxyModel {
                id: sfpModel
                filters: [
                    ValueFilter {
                        enabled: true
                        roleName: "installationId"
                        value: root.installationId
                        inverted: true
                    }
                ]
            }

            delegate: StatusSyncDeviceDelegate {
                width: ListView.view.width
                enabled: false
                deviceName: model.name
                deviceType: model.deviceType
                timestamp: model.timestamp
                isCurrentDevice: model.isCurrentDevice
            }
        }
    }
}
