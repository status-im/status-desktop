import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2
import utils 1.0
import shared.popups 1.0

import AppLayouts.Chat.controls.community 1.0
import AppLayouts.Chat.helpers 1.0

StatusScrollView {
    id: root

    property var store
    property int viewWidth: 560 // by design

    signal editPermission(int index, var holidings, var permission, var channels, bool isPrivate)
    signal removePermission(int index)

    QtObject {
        id: d
        property int permissionIndexToRemove

        function holdingsTextFormat(type, name, amount) {
            return CommunityPermissionsHelpers.setHoldingsTextFormat(type, name, amount)
        }
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height + mainLayout.anchors.topMargin

    onRemovePermission: {
        d.permissionIndexToRemove = index
        Global.openPopup(deletePopup)
    }

    ColumnLayout {
        id: mainLayout
        width: root.viewWidth
        spacing: 24

        Repeater {
            model: root.store.permissionsModel
            delegate: PermissionItem {
                Layout.preferredWidth: root.viewWidth
                holdingsListModel: SortFilterProxyModel {
                    sourceModel: model.holdingsListModel

                    proxyRoles: ExpressionRole {
                        name: "text"
                        // Direct call for singleton function is not handled properly by SortFilterProxyModel that's why `holdingsTextFormat` is used instead.
                        expression: d.holdingsTextFormat(model.type, model.name, model.amount)
                   }
                }
                permissionName: model.permissionsObjectModel.text
                permissionImageSource: model.permissionsObjectModel.imageSource
                channelsListModel: SortFilterProxyModel {
                    sourceModel: model.channelsListModel

                    proxyRoles: [
                        ExpressionRole {
                            name: "text"
                            expression: model.name
                        },
                        ExpressionRole {
                        name: "imageSource"
                        expression: model.iconSource
                    }
                   ]
                }
                isPrivate: model.isPrivate

                onEditClicked: root.editPermission(model.index, model.holdingsListModel, model.permissionsObjectModel, model.channelsListModel, model.isPrivate)
                onDuplicateClicked: store.duplicatePermission(model.index)
                onRemoveClicked: root.removePermission(model.index)
            }
        }
    }

    Component {
        id: deletePopup
        ConfirmationDialog {
            id: declineAllDialog
            header.title: qsTr("Sure you want to delete permission")
            confirmationText: qsTr("If you delete this permission, any of your community members who rely on this permission will loose the access this permission gives them.")
            onConfirmButtonClicked: {
                store.removePermission(d.permissionIndexToRemove)
                close()
            }
        }
    }

}
