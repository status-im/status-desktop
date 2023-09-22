import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared 1.0
import shared.status 1.0

SettingsContentBase {
    id: root

    property var store

    // TODO when we re-implement check for updates, put isProduction back
    titleRowComponentLoader.active: false //root.store.isProduction
    titleRowComponentLoader.sourceComponent: StatusButton {
        size: StatusBaseButton.Size.Small
        text: qsTr("Check for updates")
        onClicked: {
            root.store.checkForUpdates()
        }
    }

    component LinkItem: StatusListItem {
        Layout.fillWidth: true
        components: [
            StatusIcon {
                icon: "external-link"
                color: Theme.palette.directColor1
            }
        ]
    }

    component DocumentItem: StatusListItem {
        Layout.fillWidth: true
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.directColor1
            }
        ]
    }

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        Column {
            Layout.fillWidth: true
            StatusIcon {
                id: statusIcon
                width: 80
                height: 80
                icon: root.store.isProduction ? Style.svg("status-logo-circle") : Style.svg("status-logo-dev-circle")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: 1; height: 8}

            StatusLinkText {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 22
                font.bold: true
                normalColor: Theme.palette.directColor1
                text: (root.store.isProduction ? "" : "git:") + root.store.getCurrentVersion()
                onClicked: root.store.getReleaseNotes()
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Current Version")
            }

            Item { width: 1; height: 17}

            StatusLinkText {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 17
                font.bold: true
                normalColor: Theme.palette.directColor1
                text: root.store.getStatusGoVersion()
                onClicked: root.store.openLink("https://github.com/status-im/status-go/tree/v%1".arg(root.store.getStatusGoVersion()))
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Style.current.additionalTextSize
                text: qsTr("Status Go Version")
            }

            Item { width: 1; height: 17}

            StatusButton {
                anchors.horizontalCenter: parent.horizontalCenter
                size: StatusBaseButton.Size.Small
                icon.name: "info"
                text: qsTr("Release Notes")
                visible: root.store.isProduction
                onClicked: root.store.getReleaseNotes()
            }
        } // Column

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            LinkItem {
                title: qsTr("Status Manifesto")
                Layout.fillWidth: true
                onClicked: root.store.openLink("https://status.app/manifesto")
            }

            StatusDialogDivider {
                Layout.fillWidth: true
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                text: qsTr("Status desktop’s GitHub Repositories")
                color: Style.current.secondaryText
            }

            LinkItem {
                title: qsTr("status-desktop")
                onClicked: root.store.openLink("https://github.com/status-im/status-desktop")
            }

            LinkItem {
                title: qsTr("status-go")
                onClicked: root.store.openLink("https://github.com/status-im/status-go")
            }

            LinkItem {
                title: qsTr("StatusQ")
                onClicked: root.store.openLink("https://github.com/status-im/status-desktop/tree/master/ui/StatusQ")
            }

            LinkItem {
                title: qsTr("go-waku")
                onClicked: root.store.openLink("https://github.com/status-im/go-waku")
            }

            StatusDialogDivider {
                Layout.fillWidth: true
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                text: qsTr("Legal & Privacy Documents")
                color: Style.current.secondaryText
            }

            DocumentItem {
                title: qsTr("Terms of Use")
                onClicked: Global.changeAppSectionBySectionType(Constants.appSection.profile,
                                                                Constants.settingsSubsection.about_terms)
            }

            DocumentItem {
                title: qsTr("Privacy Statement")
                onClicked: Global.changeAppSectionBySectionType(Constants.appSection.profile,
                                                                Constants.settingsSubsection.about_privacy)
            }

            LinkItem {
                title: qsTr("Software License")
                onClicked: root.store.openLink("https://github.com/status-im/status-desktop/blob/master/LICENSE.md")
            }
        }
    }
}
