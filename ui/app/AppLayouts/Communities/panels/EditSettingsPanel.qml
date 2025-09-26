import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Popups
import StatusQ.Core.Theme

import AppLayouts.Communities.controls
import AppLayouts.Communities.popups

import utils

StatusScrollView {
    id: root
    objectName: "communityEditPanelScrollView"

    property int preferredContentWidth: width
    property int internalRightPadding: 0

    property alias name: baseLayout.name
    property alias description: baseLayout.description
    property alias introMessage: introMessageTextInput.text
    property alias outroMessage: outroMessageTextInput.text
    property alias color: baseLayout.color
    property alias tags: baseLayout.tags
    property alias selectedTags: baseLayout.selectedTags
    property alias options: baseLayout.options

    property bool shardingEnabled
    property int shardIndex
    property bool shardingInProgress
    property string pubsubTopic
    property string pubsubTopicKey

    property alias logoImageData: baseLayout.logoImageData
    property alias logoImagePath: baseLayout.logoImagePath
    property alias logoCropRect: baseLayout.logoCropRect
    property alias bannerImageData: baseLayout.bannerImageData
    property alias bannerPath: baseLayout.bannerPath
    property alias bannerCropRect: baseLayout.bannerCropRect

    property size bottomReservedSpace: Qt.size(0, 0)
    property bool bottomReservedSpaceActive: false

    readonly property bool saveChangesButtonEnabled: !((baseLayout.isNameDirty && !baseLayout.isNameValid) ||
                                                       (baseLayout.isDescriptionDirty && !baseLayout.isDescriptionValid) ||
                                                       (introMessageTextInput.input.dirty && !introMessageTextInput.valid) ||
                                                       (outroMessageTextInput.input.dirty && !outroMessageTextInput.valid))

    signal shardIndexEdited(int shardIndex)

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout
        spacing: Theme.padding

        width: Math.min(root.preferredContentWidth,
                        root.availableWidth - root.internalRightPadding)

        EditCommunitySettingsForm {
            id: baseLayout

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: -baseLayout.spacing
            Layout.bottomMargin: 2
        }
        IntroMessageInput {
            id: introMessageTextInput
            input.edit.objectName: "editCommunityIntroInput"
            Layout.fillWidth: true
            minimumHeight: 482
            maximumHeight: 482
        }

        OutroMessageInput {
            id: outroMessageTextInput
            input.edit.objectName: "editCommunityOutroInput"
            Layout.fillWidth: true
        }

        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: -baseLayout.spacing
            Layout.bottomMargin: 2
            visible: root.shardingEnabled
        }

        RowLayout {
            spacing: Theme.halfPadding
            visible: root.shardingEnabled

            readonly property bool shardingActive: root.shardIndex !== -1

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Community sharding")
            }
            Item { Layout.fillWidth: true }
            StatusBaseText {
                color: Theme.palette.baseColor1
                visible: parent.shardingActive
                text: qsTr("Active: on shard #%1").arg(root.shardIndex)
            }
            StatusButton {
                size: StatusBaseButton.Size.Small
                text: parent.shardingActive ? qsTr("Manage") : qsTr("Make %1 a sharded community").arg(root.name)
                loading: root.shardingInProgress
                onClicked: parent.shardingActive ? Global.openPopup(manageShardingPopupCmp) : Global.openPopup(enableShardingPopupCmp)
            }
        }

        Item {
            // settingsDirtyToastMessage placeholder
            visible: root.bottomReservedSpaceActive
            implicitWidth: root.bottomReservedSpace.width
            implicitHeight: root.bottomReservedSpace.height
        }

        Component {
            id: enableShardingPopupCmp
            EnableShardingPopup {
                id: enableShardingPopup
                destroyOnClose: true
                communityName: root.name
                shardIndex: root.shardIndex
                pubsubTopic: '{"pubsubTopic":"%1", "publicKey":"%2"}'.arg(root.pubsubTopic).arg(root.pubsubTopicKey)
                shardingInProgress: root.shardingInProgress

                onShardIndexChanged: root.shardIndexEdited(shardIndex)
                onShardingInProgressChanged: if (!shardingInProgress) {
                    // bring back the binding
                    enableShardingPopup.shardIndex = Qt.binding(() => root.shardIndex)
                }
            }
        }

        Component {
            id: manageShardingPopupCmp
            ManageShardingPopup {
                id: manageShardingPopup
                destroyOnClose: true
                communityName: root.name
                shardIndex: root.shardIndex
                pubsubTopic: '{"pubsubTopic":"%1", "publicKey":"%2"}'.arg(root.pubsubTopic).arg(root.pubsubTopicKey)

                onDisableShardingRequested: root.shardIndexEdited(-1)
                onEditShardIndexRequested: Global.openPopup(enableShardingPopupCmp)
            }
        }
    }
}
