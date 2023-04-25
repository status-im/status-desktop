import SortFilterProxyModel 0.2

import AppLayouts.Chat.helpers 1.0
import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.controls.community 1.0

import StatusQ.Core.Utils 0.1

import utils 1.0

SortFilterProxyModel {
    property var assetsModel
    property var collectiblesModel

    readonly property ModelChangeTracker _assetsChanges: ModelChangeTracker {
        model: assetsModel
    }

    readonly property ModelChangeTracker _collectiblesChanges: ModelChangeTracker {
        model: collectiblesModel
    }

    proxyRoles: [
        ExpressionRole {
            name: "text"

            function getName(type, key) {
                if (type === HoldingTypes.Type.Ens)
                    return key

                const model = type === HoldingTypes.Type.Asset
                            ? assetsModel
                            : collectiblesModel
                const item = CommunityPermissionsHelpers.getTokenByKey(model, key)

                return item ? item.shortName || item.name : ""
            }

            function getText(type, key, amount) {
                const name = getName(type, key)

                return CommunityPermissionsHelpers.setHoldingsTextFormat(
                            type, name, amount)
            }

            // Direct call for singleton function is not handled properly by
            // SortFilterProxyModel that's why helper function is used instead.
            expression: {
                _assetsChanges.revision
                _collectiblesChanges.revision
                return getText(model.type, model.key, model.amount)
            }
        },
        ExpressionRole {
            name: "imageSource"

            function getIcon(type, key) {
                if (type === HoldingTypes.Type.Ens)
                    return Style.png("tokens/ENS")

                const model = type === HoldingTypes.Type.Asset
                            ? assetsModel : collectiblesModel

                return CommunityPermissionsHelpers.getTokenIconByKey(model, key)
            }

            expression: {
                _assetsChanges.revision
                _collectiblesChanges.revision
                return getIcon(model.type, model.key)
            }
        },
        ExpressionRole {
            name: "operator"

            // Direct call for singleton enum is not handled properly by SortFilterProxyModel.
            readonly property int none: OperatorsUtils.Operators.None

            expression: none
        }
    ]
}
