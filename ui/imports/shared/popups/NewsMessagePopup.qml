import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import mainui.activitycenter.helpers 1.0

import shared 1.0
import utils 1.0

StatusDialog {
    id: root

    property var notification
    property string notificationId
    property var activityCenterNotifications
    signal linkClicked(string link)

    Component.onCompleted: {
        if (!root.notification && root.notificationId) {
            notificationModelEntryLoader.active = true
            root.notification = notificationModelEntryLoader.item.notification
        }
    }

    width: 480
    padding: Theme.bigPadding

    header: StatusDialogHeader {
        StatusDateGroupLabel {
            id: dateGroupLabel
            messageTimestamp: notification ? notification.timestamp : 0
            // Hidden label to get the string
            visible: false
        }

        headline.title: notification.newsTitle
        headline.subtitle: dateGroupLabel.text
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: Theme.png("status-logo-icon")
            asset.isImage: true
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 0

        Loader {
            id: notificationModelEntryLoader
            active: false // Only enabled if we do not have a notification and need to get it from the model

            sourceComponent: NotificationModelEntry {
                notificationId: root.notificationId
                activityCenterNotifications: root.activityCenterNotifications
            }
        }

        Loader {
            active: !!notification.newsImageUrl

            Layout.bottomMargin: active ? Theme.bigPadding : 0
            Layout.fillWidth: true
            Layout.preferredHeight: active ? 300 : 0

            sourceComponent: StatusRoundedImage {
                image.source: notification.newsImageUrl
                color: "transparent"
                border.color: root.backgroundColor
                border.width: 1
                radius: 16
            }
        }

        StatusBaseText {
            // Temporary fix to the HTML being present in the content
            // TODO remove when it's handled on the Web side
            text: CoreUtils.Utils.stripHtmlPreserveBreaks(notification.newsContent)
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
        }
    }
    footer: StatusDialogFooter {
        visible: !!notification.newsLink

        rightButtons: ObjectModel {
            StatusButton {
                text: !!notification.newsLinkLabel ? notification.newsLinkLabel : qsTr("Visit the website")
                icon.name: "external"
                onClicked: root.linkClicked(root.notification.newsLink)
            }
        }
    }
}
