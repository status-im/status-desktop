import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1

import SortFilterProxyModel 0.2
import shared.popups 1.0
import utils 1.0

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

StatusScrollView {
    id: root

    required property var permissionsModel
    required property var assetsModel
    required property var collectiblesModel
    required property var channelsModel

    // id, name, image, color, owner, admin properties expected
    required property var communityDetails

    property int viewWidth: 560 // by design

    signal editPermissionRequested(int index)
    signal duplicatePermissionRequested(int index)
    signal removePermissionRequested(int index)

    readonly property alias count: repeater.count

    padding: 0
    topPadding: count ? 16 : 0

    QtObject {
        id: d

        property int permissionIndexToRemove
    }

    ColumnLayout {
        id: mainLayout
        width: root.viewWidth
        spacing: 24

        ListModel {
            id: communityItemModel

            Component.onCompleted: {
                append({
                    text: root.communityDetails.name,
                    imageSource: root.communityDetails.image,
                    color: root.communityDetails.color
                })
            }
        }

        IntroPanel {
            Layout.fillWidth: true

            visible: root.count === 0

            image: Style.png("community/permissions2_3")
            title: qsTr("Permissions")
            subtitle: qsTr("You can manage your community by creating and issuing membership and access permissions")
            checkersModel: [
                qsTr("Give individual members access to private channels"),
                qsTr("Monetise your community with subscriptions and fees"),
                qsTr("Require holding a token or NFT to obtain exclusive membership rights")
            ]
        }

        Repeater {
            id: repeater

            model: root.permissionsModel

            delegate: PermissionItem {
                Layout.fillWidth: true

                holdingsListModel: HoldingsSelectionModel {
                    sourceModel: model.holdingsListModel
                    assetsModel: root.assetsModel
                    collectiblesModel: root.collectiblesModel
                }

                permissionType: model.permissionType

                ChannelsSelectionModel {
                    id: channelsSelectionModel

                    sourceModel: model.channelsListModel ?? null
                    channelsModel: root.channelsModel
                }

                channelsListModel: channelsSelectionModel.count
                                   ? channelsSelectionModel : communityItemModel
                isPrivate: model.isPrivate

                showButtons: root.communityDetails.owner || (root.communityDetails.admin && model.permissionType !== PermissionTypes.Type.Admin)

                onEditClicked: root.editPermissionRequested(model.index)
                onDuplicateClicked: root.duplicatePermissionRequested(model.index)

                onRemoveClicked: {
                    d.permissionIndexToRemove = index
                    declineAllDialog.open()
                }
            }
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
