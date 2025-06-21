import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.status 1.0
import shared.popups 1.0
import utils 1.0

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

ColumnLayout {
    id: root
    width: root.viewWidth
    property int topPadding: count ? 16 : 0
    spacing: 24

    QtObject {
        id: d

        property int permissionIndexToRemove
    }

    required property var permissionsModel
    required property var assetsModel
    required property var collectiblesModel
    required property var channelsModel

    // id, name, image, color, owner, admin properties expected
    required property QtObject communityDetails

    property int viewWidth: 560 // by design
    property bool viewOnlyCanAddReaction
    property bool showChannelOptions: false
    property bool allowIntroPanel: true

    signal editPermissionRequested(int index)
    signal duplicatePermissionRequested(int index)
    signal removePermissionRequested(int index)
    signal userRestrictionsToggled(bool checked)

    readonly property alias count: listView.count

    Connections {
        target: root.communityDetails
        function onNameChanged(){
            resetCommunityItemModel()
        }
        function onImageChanged(){
            resetCommunityItemModel()
        }
        function onColorChanged(){
            resetCommunityItemModel()
        }
    }

    function resetCommunityItemModel() {
        communityItemModel.clear()
        communityItemModel.append({
                   text: root.communityDetails.name,
                   imageSource: root.communityDetails.image,
                   color: root.communityDetails.color
               })
    }

    ListModel {
        id: communityItemModel
        Component.onCompleted: resetCommunityItemModel()
    }

    IntroPanel {
        Layout.fillWidth: true

        visible: (root.count === 0 && root.allowIntroPanel)

        image: Theme.png("community/permissions2_3")
        title: qsTr("Permissions")
        subtitle: qsTr("You can manage your community by creating and issuing membership and access permissions")
        checkersModel: [
            qsTr("Give individual members access to private channels"),
            qsTr("Monetise your community with subscriptions and fees"),
            qsTr("Require holding a token or NFT to obtain exclusive membership rights")
        ]
    }

    StatusListView {
        id: listView
        reuseItems: true
        model: root.permissionsModel
        spacing: 24
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: contentHeight
        Layout.topMargin: root.topPadding

        delegate: PermissionItem {
            width: root.viewWidth

            holdingsListModel: HoldingsSelectionModel {
                sourceModel: model.holdingsListModel
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
            }

            permissionType: model.permissionType
            permissionState: model.permissionState // TODO: Backend!

            LeftJoinModel {
                id: channelsSelectionModel

                leftModel: model.channelsListModel ?? null
                rightModel: root.channelsModel
                joinRole: "key"
            }

            channelsListModel: model.channelsListModel.rowCount()
                                    ? channelsSelectionModel : communityItemModel
            isPrivate: model.isPrivate

            showButtons: (model.permissionType !== PermissionTypes.Type.TokenMaster &&
                          model.permissionType !== PermissionTypes.Type.Owner) &&
                         (!!root.communityDetails && (root.communityDetails.owner ||
                                                      ((root.communityDetails.admin || root.communityDetails.tokenMaster) && model.permissionType !== PermissionTypes.Type.Admin)))

            onEditClicked: root.editPermissionRequested(model.index)
            onDuplicateClicked: root.duplicatePermissionRequested(model.index)

            onRemoveClicked: {
                d.permissionIndexToRemove = index
                declineAllDialog.open()
            }
        }
    }

    StatusBaseText {
        id: noPermissionsLabel
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: (root.count === 0 && root.showChannelOptions)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("No channel permissions")
        color: Theme.palette.secondaryText
    }

    StatusIconSwitch {
        Layout.fillWidth: true
        padding: 0

        visible: root.showChannelOptions
        title: qsTr("Users with view only permissions can add reactions")
        icon: "emojis"
        checked: root.viewOnlyCanAddReaction
        onToggled: {
            root.userRestrictionsToggled(checked);
        }
    }

    ConfirmationDialog {
        id: declineAllDialog

        headerSettings.title: qsTr("Sure you want to delete permission")
        confirmationText: qsTr("If you delete this permission, any of your community members who rely on this permission will lose the access this permission gives them.")

        onConfirmButtonClicked: {
            root.removePermissionRequested(d.permissionIndexToRemove)
            close()
        }
    }
}
