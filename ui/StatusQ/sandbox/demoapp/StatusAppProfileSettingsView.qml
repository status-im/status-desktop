import QtQuick 2.12
import QtQuick.Controls 2.14

import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "data" 1.0

StatusSectionLayout {
    id: root

    leftPanel: Item {
        anchors.fill: parent

        StatusNavigationPanelHeadline {
            id: profileHeadline
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Profile"
        }

        StatusScrollView {
            id: scrollView
            anchors.top: profileHeadline.bottom
            anchors.topMargin: 16
            anchors.bottom: parent.bottom
            width: parent.width

            contentHeight: profileMenuItems
            contentWidth: availableWidth
            clip: true

            Column {
                id: profileMenuItems

                width: scrollView.availableWidth
                spacing: 4

                Repeater {
                    model: Models.demoProfileGeneralMenuItems
                    delegate: StatusNavigationListItem {
                        title: model.title
                        asset.name: model.icon
                    }
                }

                StatusListSectionHeadline { text: "Settings" }

                Repeater {
                    model: Models.demoProfileSettingsMenuItems
                    delegate: StatusNavigationListItem {
                        title: model.title
                        asset.name: model.icon
                    }
                }

                Item {
                    id: invisibleSeparator
                    height: 16
                    width: parent.width
                }

                Repeater {
                    model: Models.demoProfileOtherMenuItems
                    delegate: StatusNavigationListItem {
                        title: model.title
                        asset.name: model.icon
                    }
                }
            }
        }
    }

    rightPanel: Item {
        anchors.fill: parent
    }
}
