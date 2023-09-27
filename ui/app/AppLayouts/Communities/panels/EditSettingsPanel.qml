import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.popups 1.0

import utils 1.0

StatusScrollView {
    id: root
    objectName: "communityEditPanelScrollView"

    property alias name: baseLayout.name
    property alias description: baseLayout.description
    property alias introMessage: introMessageTextInput.text
    property alias outroMessage: outroMessageTextInput.text
    property alias color: baseLayout.color
    property alias tags: baseLayout.tags
    property alias selectedTags: baseLayout.selectedTags
    property alias options: baseLayout.options
    property string communityId
    property bool communityShardingEnabled
    property int communityShardIndex: -1

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

    padding: 0

    ColumnLayout {
        id: mainLayout
        width: baseLayout.width
        spacing: Style.current.padding
        EditCommunitySettingsForm {
            id: baseLayout
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
            visible: root.communityShardingEnabled
        }

        RowLayout {
            spacing: Style.current.halfPadding
            visible: root.communityShardingEnabled

            readonly property bool shardingActive: root.communityShardIndex !== -1

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Community sharding")
            }
            Item { Layout.fillWidth: true }
            StatusBaseText {
                color: Theme.palette.baseColor1
                visible: parent.shardingActive
                text: qsTr("Active: on shard #%1").arg(root.communityShardIndex)
            }
            StatusButton {
                size: StatusBaseButton.Size.Small
                text: parent.shardingActive ? qsTr("Manage") : qsTr("Make %1 a sharded community").arg(root.name)
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
                destroyOnClose: true
                communityName: root.name
                publicKey: root.communityId
                shardingInProgress: false // TODO community sharding backend: set to "true" when generating the pubSub topic, or migrating
                onEnableSharding: {
                    console.warn("TODO: enable community sharding for shardIndex:", shardIndex) // TODO community sharding backend
                    root.communityShardIndex = shardIndex
                }
            }
        }

        Component {
            id: manageShardingPopupCmp
            ManageShardingPopup {
                destroyOnClose: true
                communityName: root.name
                shardIndex: root.communityShardIndex
                pubSubTopic: '{"pubsubTopic":"/waku/2/rs/16/%1", "publicKey":"%2"}'.arg(shardIndex).arg(root.communityId) // TODO community sharding backend
                onDisableShardingRequested: {
                    root.communityShardIndex = -1 // TODO community sharding backend
                }
                onEditShardIndexRequested: {
                    Global.openPopup(enableShardingPopupCmp, {initialShardIndex: root.communityShardIndex})
                }
            }
        }
    }
}
