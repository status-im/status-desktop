import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import AppLayouts.Communities.layouts
import AppLayouts.Communities.panels
import AppLayouts.Communities.popups
import AppLayouts.Communities.helpers

import shared.popups

import utils

StackLayout {
    id: root

    property int preferredContentWidth: width
    property int internalRightPadding: 0

    required property bool isOwner
    required property bool isAdmin
    required property bool isTokenMaster

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

    property bool archiveSupporVisible: true
    property bool editable: false
    property bool isControlNode: false
    property bool communitySettingsDisabled
    property var ownerToken: null

    property string overviewChartData: ""

    property bool shardingEnabled
    property int shardIndex: -1
    property bool shardingInProgress
    property string pubsubTopic
    property string pubsubTopicKey

    property bool isTokenDeployed: !!root.ownerToken && root.ownerToken.deployState === Constants.ContractTransactionStatus.Completed

    property bool isMobile

    // Community transfer ownership related props:
    required property bool isPendingOwnershipRequest
    signal finaliseOwnershipClicked

    function navigateBack() {
        if (editSettingsPanelLoader.item.dirty)
            settingsDirtyToastMessage.notifyDirty()
        else
            root.currentIndex = 0
    }

    signal collectCommunityMetricsMessagesCount(var intervals)

    signal edited(Item item) // item containing edited fields (name, description, logoImagePath, color, options, etc..)

    signal airdropTokensClicked
    signal exportControlNodeClicked
    signal importControlNodeClicked
    signal mintOwnerTokenClicked

    signal shardIndexEdited(int shardIndex)

    clip: true

    Component {
        id: mainSettingsPageComp
        ColumnLayout {
            spacing: 16

            RowLayout {
                spacing: 16

                ColumnLayout {
                    id: titleColumn

                    Layout.fillWidth: true

                    StatusBaseText {
                        id: nameText
                        objectName: "communityOverviewSettingsCommunityName"
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontSize28
                        font.bold: true
                        font.letterSpacing: -0.4
                        color: Theme.palette.directColor1
                        wrapMode: Text.Wrap
                        text: root.name
                    }

                    StatusBaseText {
                        id: descriptionText
                        objectName: "communityOverviewSettingsCommunityDescription"
                        Layout.fillWidth: true
                        font.pixelSize: Theme.primaryTextFontSize
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                        text: root.description
                    }
                }

                StatusButton {
                    Layout.preferredHeight: 38
                    Layout.alignment: Qt.AlignTop
                    objectName: "communityOverviewSettingsTransferOwnershipButton"
                    visible: root.isOwner && !root.isMobile
                    text: qsTr("Transfer ownership")
                    size: StatusBaseButton.Size.Small

                    onClicked: {
                        if(!!root.ownerToken && root.ownerToken.deployState === Constants.ContractTransactionStatus.Completed) {
                            Global.openTransferOwnershipPopup(root.communityId,
                                                              root.name,
                                                              root.logoImageData,
                                                              {
                                                                  key: "0",
                                                                  privilegesLevel: root.ownerToken.privilegesLevel,
                                                                  chainId: root.ownerToken.chainId,
                                                                  name: root.ownerToken.name,
                                                                  artworkSource: root.ownerToken.image,
                                                                  accountAddress: root.ownerToken.accountAddress.toLowerCase(),
                                                                  tokenAddress: root.ownerToken.tokenAddress.toLowerCase()
                                                              })
                        } else {
                            Global.openPopup(transferOwnershipAlertPopup, { mode: TransferOwnershipAlertPopup.Mode.TransferOwnership })
                        }
                    }
                }

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
                model: JSON.parse(root.overviewChartData)
                onCollectCommunityMetricsMessagesCount: (intervals) => {
                    root.collectCommunityMetricsMessagesCount(intervals)
                }
                Layout.topMargin: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 16

                Connections {
                    target: root
                    function onCommunityIdChanged() {
                        reset()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: mainSettingsPage.footer.active
                implicitHeight: 1
                color: Theme.palette.statusMenu.separatorColor
            }
        }
    }

    Component {
        id: overviewSettingsFooterComp

        OverviewSettingsFooter {
            rightPadding: 64
            leftPadding: 64
            bottomPadding: 64
            topPadding: 0
            communityName: root.name
            communityColor: root.color
            isControlNode: root.isControlNode
            isPendingOwnershipRequest: root.isPendingOwnershipRequest

            onExportControlNodeClicked:{
                if(root.isTokenDeployed) {
                    root.exportControlNodeClicked()
                } else {
                    Global.openPopup(transferOwnershipAlertPopup, { mode: TransferOwnershipAlertPopup.Mode.MoveControlNode })
                }
            }
            onImportControlNodeClicked: root.importControlNodeClicked()
            onFinaliseOwnershipTransferClicked: root.finaliseOwnershipClicked()
            onLearnMoreClicked: Global.requestOpenLink(Constants.statusHelpLinkPrefix + "communities/about-the-control-node-in-status-communities")
        }
    }

    Component {
        id: disabledSettingsBannerComp
        StatusInfoBoxPanel {
            title: qsTr("Community administration is disabled when in testnet mode")
            text: qsTr("To access your %1 community admin area, you need to turn off testnet mode.").arg(root.name)
            icon: "settings"
            iconType: StatusInfoBoxPanel.Type.Warning
            buttonText: qsTr("Turn off testnet mode")
            onClicked: Global.openTestnetPopup()
        }
    }

    SettingsPage {
        id: mainSettingsPage

        Layout.fillWidth: !root.communitySettingsDisabled
        Layout.preferredWidth: root.communitySettingsDisabled ? 560 + leftPadding + rightPadding : -1
        Layout.fillHeight: !root.communitySettingsDisabled
        rightPadding: 64
        bottomPadding: 50
        topPadding: 0
        header: null
        contentItem: Loader {
            sourceComponent: root.communitySettingsDisabled ? disabledSettingsBannerComp : mainSettingsPageComp
        }

        footer: Loader {
            sourceComponent: overviewSettingsFooterComp
            active: {
                if (root.communitySettingsDisabled)
                    return false
                if (root.isMobile)
                    return false
                if (root.isAdmin || root.isTokenMaster)
                    return root.isPendingOwnershipRequest // not allowed for admin or TM unless there's the pending request
                return root.isControlNode || root.isTokenDeployed
            }
        }
    }

    SettingsPage {
        id: editCommunityPage

        title: qsTr("Edit Community")
        preferredHeaderContentWidth: root.preferredContentWidth

        contentItem: Loader {
            id: editSettingsPanelLoader

            active: false

            onVisibleChanged: {
                if (visible) {
                    active = true
                }
            }

            function reloadContent() {
                active = false
                active = true
            }

            sourceComponent: EditSettingsPanel {
                id: editSettingsPanel

                preferredContentWidth: root.preferredContentWidth
                internalRightPadding: root.internalRightPadding

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
                    archiveSupporVisible: root.archiveSupporVisible && !root.isMobile
                    requestToJoinEnabled: root.requestToJoinEnabled
                    pinMessagesEnabled: root.pinMessagesEnabled
                }

                shardingEnabled: root.shardingEnabled
                shardIndex: root.shardIndex
                shardingInProgress: root.shardingInProgress
                pubsubTopic: root.pubsubTopic
                pubsubTopicKey: root.pubsubTopicKey

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

                onShardIndexEdited: root.shardIndexEdited(shardIndex)
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
            visible: active

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

    Component {
        id: transferOwnershipAlertPopup

        TransferOwnershipAlertPopup {
            destroyOnClose: true
            communityName: root.name
            communityLogo: root.logoImageData

            onMintClicked: root.mintOwnerTokenClicked()
        }
    }
}
