import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils
import mainui.activitycenter.stores


ActivityNotificationBase {
    id: root

    required property string accountName
    required property int type // Possible values [InstallationType]

    signal moreDetailsClicked

    function setType(notification) {
        if (notification) {
            switch (notification.notificationType) {
                case ActivityCenterStore.ActivityCenterNotificationType.NewInstallationReceived:
                    return ActivityNotificationNewDevice.InstallationType.Received

                case ActivityCenterStore.ActivityCenterNotificationType.NewInstallationCreated:
                    return ActivityNotificationNewDevice.InstallationType.Created
            }
        }
        return ActivityNotificationNewDevice.InstallationType.Unknown
    }

    enum InstallationType {
        Unknown,
        Received,
        Created
    }

    QtObject {
        id: d

        property string title: ""
        property string info: ""
        property string assetColor: Theme.palette.primaryColor1
        property string assetName: d.desktopAssetName
        property string assetBgColor: Theme.palette.primaryColor3
        property string ctaText: qsTr("More details")

        readonly property string desktopAssetName: "desktop"
    }

    bodyComponent: RowLayout {
        spacing: 8

        StatusSmartIdenticon {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
            Layout.topMargin: 2

            asset {
                width: 24
                height: width
                name: d.assetName
                color: d.assetColor
                bgWidth: 40
                bgHeight: 40
                bgColor: d.assetBgColor
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            StatusMessageHeader {
                Layout.fillWidth: true
                displayNameLabel.text: d.title
                timestamp: root.notification.timestamp
            }

            RowLayout {
                spacing: Theme.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    text: d.info
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: Theme.palette.baseColor1
                }
            }
        }
    }

    ctaComponent: StatusFlatButton {
                    size: StatusBaseButton.Size.Small
                    text: d.ctaText
                    onClicked: {
                        root.moreDetailsClicked()
                    }
                }

    states: [
        State {
            when: root.type === ActivityNotificationNewDevice.InstallationType.Received
            PropertyChanges {
                target: d
                title: qsTr("New device detected")
                info: qsTr("New device with %1 profile has been detected.").arg(accountName)
            }
        },
        State {
            when: root.type === ActivityNotificationNewDevice.InstallationType.Created
            PropertyChanges {
                target: d
                title: qsTr("Sync your profile")
                info: qsTr("Check your other device for a pairing request.")
            }
        }
    ]
}
