import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import shared 1.0
import utils 1.0

StatusDialog {
    id: root

    required property var notification
    signal linkClicked()

    anchors.centerIn: parent
    width: 480
    padding: Theme.bigPadding

    header: StatusDialogHeader {
        StatusDateGroupLabel {
            id: dateGroupLabel
            messageTimestamp: notification ? notification.timestamp : 0
            // Hidden label to get the string
            visible: false
        }

        headline.title: notification.title
        headline.subtitle: dateGroupLabel.text
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: Theme.png("status-logo-icon")
            asset.isImage: true
        }
    }

    ColumnLayout {
        spacing: 16
        width: parent.width

        StatusRoundedImage {
            Layout.fillWidth: true
            Layout.preferredHeight: 300

            image.source: notification.imageUrl
            color: "transparent"
            border.color: root.backgroundColor
            border.width: 1
        }

        StatusBaseText {
            text: notification.content
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
        }
    }
    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: notification.linkLabel
                icon.name: "external"
                onClicked: root.linkClicked()
            }
        }
    }
}
