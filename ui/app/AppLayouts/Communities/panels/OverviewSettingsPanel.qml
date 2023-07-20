﻿import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.panels 1.0

import shared.popups 1.0

import utils 1.0

StackLayout {
    id: root

    property string communityId
    property string name
    property string description
    property string introMessage
    property string outroMessage
    property string logoImageData
    property string bannerImageData
    property rect bannerCropRect
    property color color
    property string tags
    property string selectedTags
    property bool archiveSupportEnabled
    property bool requestToJoinEnabled
    property bool pinMessagesEnabled
    property string previousPageName: (currentIndex === 1) ? qsTr("Overview") : ""

    property bool editable: false
    property bool owned: false
    property bool isControlNode: false
    property int loginType: Constants.LoginType.Password

    function navigateBack() {
        if (editSettingsPanelLoader.item.dirty)
            settingsDirtyToastMessage.notifyDirty()
        else
            root.currentIndex = 0
    }

    signal edited(Item item) // item containing edited fields (name, description, logoImagePath, color, options, etc..)

    signal inviteNewPeopleClicked
    signal airdropTokensClicked
    signal exportControlNodeClicked

    clip: true

    SettingsPage {

        rightPadding: 64
        bottomPadding: 50
        topPadding: 0
        header: null
        contentItem: ColumnLayout {
            spacing: 16
            RowLayout {
                Layout.fillWidth: true

                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 747

                    StatusBaseText {
                        id: nameText
                        objectName: "communityOverviewSettingsCommunityName"
                        Layout.fillWidth: true
                        font.pixelSize: 28
                        font.bold: true
                        font.letterSpacing: -0.4
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        text: root.name
                    }

                    StatusBaseText {
                        id: descriptionText
                        objectName: "communityOverviewSettingsCommunityDescription"
                        Layout.fillWidth: true
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        text: root.description
                    }
                }

                Item { Layout.fillWidth: true }

                StatusButton {
                    Layout.preferredHeight: 38
                    Layout.alignment: Qt.AlignTop
                    objectName: "communityOverviewSettingsEditCommunityButton"
                    visible: root.editable
                    text: qsTr("Edit Community")
                    onClicked: root.currentIndex = 1
                    size: StatusBaseButton.Size.Small
                }
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 1
                color: Theme.palette.statusMenu.separatorColor
            }

            OverviewSettingsChart {
                Layout.topMargin: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 16
            }
            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 1
                color: Theme.palette.statusMenu.separatorColor
            }
        }

        footer: OverviewSettingsFooter {
            rightPadding: 64
            leftPadding: 64
            bottomPadding: 64
            topPadding: 0
            loginType: root.loginType
            communityName: root.name
            isControlNode: root.isControlNode
            onExportControlNodeClicked: root.exportControlNodeClicked()
            //TODO update once the domain changes
            onLearnMoreClicked: Global.openLink(Constants.statusHelpLinkPrefix + "en/status-communities/about-the-control-node-in-status-communities")
        }
    }

    SettingsPage {
        id: editCommunityPage

        title: qsTr("Edit Community")

        contentItem: Loader {
            id: editSettingsPanelLoader

            function reloadContent() {
                active = false
                active = true
            }

            sourceComponent: EditSettingsPanel {
                id: editSettingsPanel

                function isValidRect(r /*rect*/) {
                    return r.width !== 0 && r.height !== 0
                }

                readonly property bool dirty:
                    root.name != name ||
                    root.description != description ||
                    root.introMessage != introMessage ||
                    root.outroMessage != outroMessage ||
                    root.archiveSupportEnabled != options.archiveSupportEnabled ||
                    root.requestToJoinEnabled != options.requestToJoinEnabled ||
                    root.pinMessagesEnabled != options.pinMessagesEnabled ||
                    root.color != color ||
                    root.selectedTags != selectedTags ||
                    root.logoImageData != logoImageData ||
                    logoImagePath.length > 0 ||
                    isValidRect(logoCropRect) ||
                    root.bannerImageData != bannerImageData ||
                    bannerPath.length > 0 ||
                    isValidRect(bannerCropRect)

                name: root.name
                description: root.description
                introMessage: root.introMessage
                outroMessage: root.outroMessage
                tags: root.tags
                selectedTags: root.selectedTags
                color: root.color
                logoImageData: root.logoImageData
                bannerImageData: root.bannerImageData

                options {
                    archiveSupportEnabled: root.archiveSupportEnabled
                    requestToJoinEnabled: root.requestToJoinEnabled
                    pinMessagesEnabled: root.pinMessagesEnabled
                }

                bottomReservedSpace:
                    Qt.size(settingsDirtyToastMessage.implicitWidth,
                            settingsDirtyToastMessage.implicitHeight +
                            settingsDirtyToastMessage.anchors.bottomMargin)

                bottomReservedSpaceActive: dirty

                Binding {
                    target: editSettingsPanel.flickable
                    property: "bottomMargin"
                    value: 24
                }
            }
        }

        SettingsDirtyToastMessage {
            id: settingsDirtyToastMessage

            z: 1
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 16
            }

            active: !!editSettingsPanelLoader.item &&
                    editSettingsPanelLoader.item.dirty

            saveChangesButtonEnabled:
                !!editSettingsPanelLoader.item &&
                editSettingsPanelLoader.item.saveChangesButtonEnabled

            onResetChangesClicked: editSettingsPanelLoader.reloadContent()

            onSaveChangesClicked: {
                root.currentIndex = 0
                root.edited(editSettingsPanelLoader.item)
                editSettingsPanelLoader.reloadContent()
            }
        }
    }
}
