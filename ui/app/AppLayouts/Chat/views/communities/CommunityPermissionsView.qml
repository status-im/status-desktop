import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2
import utils 1.0

import AppLayouts.Chat.controls.community 1.0

StatusScrollView {
    id: root

    property var store
    property int viewWidth: 560 // by design

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height + mainLayout.anchors.topMargin

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
                        expression: root.store.setHoldingsTextFormat(model.type, model.name, model.amount)
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

                onEditClicked: store.editPermission(model.index)
                onDuplicateClicked: store.duplicatePermission(model.index)
                onRemoveClicked: store.removePermission(model.index)
            }
        }
    }
}
