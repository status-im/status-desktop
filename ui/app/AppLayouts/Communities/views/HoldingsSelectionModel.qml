import SortFilterProxyModel 0.2

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.controls 1.0

import StatusQ.Core.Utils 0.1
import StatusQ 0.1

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
        FastExpressionRole {
            name: "text"

            function getName(type, item, key) {
                if (type === Constants.TokenType.ENS)
                    return key
                return item ? item.symbol || item.shortName || item.name : ""
            }

            function getDecimals(type, item) {
                if (type !== Constants.TokenType.ERC20)
                    return 0
                return item.decimals
            }

            function getText(type, key, amount) {
                const model = type === Constants.TokenType.ERC20
                            ? assetsModel
                            : collectiblesModel
                const item = PermissionsHelpers.getTokenByKey(model, key)

                const name = getName(type, item, key)
                const decimals = getDecimals(type, item)

                return PermissionsHelpers.setHoldingsTextFormat(
                            type, name, amount, decimals)
            }

            // Direct call for singleton function is not handled properly by
            // SortFilterProxyModel that's why helper function is used instead.
            expression: {
                _assetsChanges.revision
                _collectiblesChanges.revision
                return getText(model.type, model.key, model.amount)
            }
            expectedRoles: ["type", "key", "amount"]
        },
        FastExpressionRole {
            name: "imageSource"

            function getIcon(type, key) {
                if (type === Constants.TokenType.ENS)
                    return Style.png("tokens/ENS")

                const model = type === Constants.TokenType.ERC20
                            ? assetsModel : collectiblesModel

                return PermissionsHelpers.getTokenIconByKey(model, key)
            }

            expression: {
                _assetsChanges.revision
                _collectiblesChanges.revision
                return getIcon(model.type, model.key)
            }
            expectedRoles: ["type", "key"]
        },
        FastExpressionRole {
            name: "operator"

            // Direct call for singleton enum is not handled properly by SortFilterProxyModel.
            readonly property int none: OperatorsUtils.Operators.None

            expression: none
        }
    ]
}
