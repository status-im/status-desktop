import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"
import "../popups"
import "../stores"

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
        property string assetColor: ""
        property string assetName: ""
        property string assetBgColor: ""
        property string ctaText: ""
        property var actionSourceComponent: undefined

        readonly property string desktopAssetName: "desktop"
    }

    bodyComponent: RowLayout {
        spacing: 8

        StatusSmartIdenticon {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Style.current.padding
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
                spacing: Style.current.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    text: d.info
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: Theme.palette.baseColor1
                }

                Loader { sourceComponent: d.actionSourceComponent }

            }
        }
    }

    ctaComponent: undefined

    states: [
        State {
            when: root.type === ActivityNotificationNewDevice.InstallationType.Received
            PropertyChanges {
                target: d
                title: qsTr("New device detected")
                info: qsTr("New device with %1 profile has been detected.").arg(accountName)
                ctaText: qsTr("More details")
                assetColor: Theme.palette.primaryColor1
                assetBgColor: Theme.palette.primaryColor3
                assetName: d.desktopAssetName
                actionSourceComponent: ctaFlatBtnComponent
            }
        },
        State {
            when: root.type === ActivityNotificationNewDevice.InstallationType.Created
            PropertyChanges {
                target: d
                title: qsTr("Sync your profile")
                info: qsTr("Check your other device for a pairing request.")
                ctaText: qsTr("More details")
                assetColor: Theme.palette.primaryColor1
                assetBgColor: Theme.palette.primaryColor3
                assetName: d.desktopAssetName
                actionSourceComponent: ctaFlatBtnComponent
            }
        }
    ]

    Component {
        id: ctaFlatBtnComponent

        StatusFlatButton {
            size: StatusBaseButton.Size.Small
            text: d.ctaText
            onClicked: {
                root.moreDetailsClicked()
            }
        }
    }
}