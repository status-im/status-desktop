import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils

import  AppLayouts.ActivityCenter.controls
import AppLayouts.ActivityCenter.helpers


ActivityNotificationBase {
    id: root

    required property int type // Possible values [FetchingState]

    signal tryAgainClicked

    function setType(notification) {
        if (notification) {
            switch (notification.notificationType) {
            case ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingFetching:
                return ActivityNotificationProfileFetching.FetchingState.Fetching
            case ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingSuccess:
                return ActivityNotificationProfileFetching.FetchingState.Success
            case ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingPartialFailure:
                return ActivityNotificationProfileFetching.FetchingState.PartialFailure
            case ActivityCenterTypes.ActivityCenterNotificationType.BackupSyncingFailure:
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

    avatarComponent: StatusSmartIdenticon {
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
    bodyComponent: ColumnLayout {
        spacing: Theme.halfPadding
        width: parent.width

        NotificationBaseHeaderRow {
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width
            primaryText: d.title
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: d.info
            font.pixelSize: Theme.additionalTextSize
            wrapMode: Text.WordWrap
            color: Theme.palette.directColor1
        }
    }

    ctaComponent: StatusLinkText {
        text: d.ctaText
        color: Theme.palette.primaryColor1
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Normal
        onClicked: root.tryAgainClicked()
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
