import SortFilterProxyModel

import AppLayouts.Communities.helpers
import AppLayouts.Communities.panels
import AppLayouts.Communities.controls

import StatusQ
import StatusQ.Core.Utils
import StatusQ.Core.Theme

import utils

SortFilterProxyModel {
    id: root

    property var assetsModel
    property var collectiblesModel
    // Returns token that matches provided key (key can be token or group key). Use it as a last option (may affect app performances, because it fetches all tokens from stautsgo).
    property var getTokenByKeyOrGroupKeyFromAllTokens: function(key){ return {}}

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

            function getText(type, key, amount, defaultText) {
                const collectibles = type !== Constants.TokenType.ERC20
                const model = type === Constants.TokenType.ERC20
                            ? assetsModel
                            : collectiblesModel

                let item = PermissionsHelpers.getTokenByKey(model, collectibles, key)
                if (Object.keys(item).length === 0) {
                    item = root.getTokenByKeyOrGroupKeyFromAllTokens(key)
                }

                let name = getName(type, item, key)
                const decimals = getDecimals(type, item)

                if (name === "")
                    name = defaultText

                return PermissionsHelpers.setHoldingsTextFormat(
                            type, name, amount, decimals)
            }

            // Direct call for singleton function is not handled properly by
            // SortFilterProxyModel that's why helper function is used instead.
            expression: {
                _assetsChanges.revision
                _collectiblesChanges.revision
                return getText(model.type, model.key, model.amount, model.symbol)
            }
            expectedRoles: ["type", "key", "amount", "symbol", "shortName"]
        },
        FastExpressionRole {
            name: "imageSource"

            function getIcon(type, key) {
                if (type === Constants.TokenType.ENS)
                    return Assets.png("tokens/ENS")

                const collectibles = type !== Constants.TokenType.ERC20
                const model = type === Constants.TokenType.ERC20
                            ? assetsModel : collectiblesModel

                let icon = PermissionsHelpers.getTokenIconByKey(model, collectibles, key)
                if (Constants.isDefaultTokenIcon(icon)) {
                    const item = root.getTokenByKeyOrGroupKeyFromAllTokens(key)
                    if (!!item){
                        icon = item.logoUri
                    }
                }

                return icon
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
