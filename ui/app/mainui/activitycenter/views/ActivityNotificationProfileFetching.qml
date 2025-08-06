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

    required property int type // Possible values [FetchingState]

    signal tryAgainClicked

    function setType(notification) {
        if (notification) {
            switch (notification.notificationType) {
                case ActivityCenterStore.ActivityCenterNotificationType.BackupSyncingFetching:
                    return ActivityNotificationProfileFetching.FetchingState.Fetching
                case ActivityCenterStore.ActivityCenterNotificationType.BackupSyncingSuccess:
                    return ActivityNotificationProfileFetching.FetchingState.Success
                case ActivityCenterStore.ActivityCenterNotificationType.BackupSyncingPartialFailure:
                    return ActivityNotificationProfileFetching.FetchingState.PartialFailure
                case ActivityCenterStore.ActivityCenterNotificationType.BackupSyncingFailure:
                    return ActivityNotificationProfileFetching.FetchingState.Failure
            }
        }
        return ActivityNotificationProfileFetching.FetchingState.Unknown
    }

    enum FetchingState {
        Unknown,
        Fetching,
        Success,
        PartialFailure,
        Failure
    }

    QtObject {
        id: d

        property string title: qsTr("Fetching profile details")
        property string info: ""
        property string badgeName: ""
        property string ctaText: ""
        property string badgeColor: ""
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
                name: "download"
                color: Theme.palette.primaryColor1
                bgWidth: 40
                bgHeight: 40
                bgColor: Theme.palette.primaryColor3
            }

            bridgeBadge.visible: true
            bridgeBadge.border.width: 2
            bridgeBadge.color: d.badgeColor
            bridgeBadge.image.source: Theme.svg(d.badgeName)
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
            root.tryAgainClicked()
        }
    }

    states: [
        State {
            when: root.type === ActivityNotificationProfileFetching.FetchingState.Fetching
            PropertyChanges {
                target: d
                info: qsTr("Fetching all data may take some time")
                badgeName: "dotsLoadings"
                ctaText: ""
                badgeColor: Theme.palette.baseColor3
            }
        },
        State {
            when: root.type === ActivityNotificationProfileFetching.FetchingState.Success
            PropertyChanges {
                target: d
                info: qsTr("Profile details fetched successfully")
                badgeName: "check"// TODO fix icon it looks bad
                ctaText: ""
                badgeColor: Theme.palette.successColor1
            }
        },
        State {
            when: root.type === ActivityNotificationProfileFetching.FetchingState.PartialFailure
            PropertyChanges {
                target: d
                info: qsTr("Some profile details could not be fetched")
                badgeName: "exclamation_outline" // TODO fix icon it looks bad
                ctaText: qsTr("Try again")
                badgeColor: Theme.palette.dangerColor1
            }
        },
        State {
            when: root.type === ActivityNotificationProfileFetching.FetchingState.Failure
            PropertyChanges {
                target: d
                info: qsTr("Profile details could not be fetched")
                badgeName: "exclamation_outline" // TODO fix icon it looks bad
                ctaText: qsTr("Try again")
                badgeColor: Theme.palette.dangerColor1
            }
        }
    ]
}