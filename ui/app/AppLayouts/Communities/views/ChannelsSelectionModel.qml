import QtQml 2.15
import SortFilterProxyModel 0.2

import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

SortFilterProxyModel {
    property var channelsModel

    readonly property QtObject _d: QtObject {
        id: d

        readonly property ModelChangeTracker tracker: ModelChangeTracker {
            model: channelsModel

            onRevisionChanged: {
                const metadata = new Map()
                const count = channelsModel.rowCount()

                for (let i = 0; i < count; i++) {
                    const item = ModelUtils.get(channelsModel, i)

                    const text = "#" + item.name
                    const imageSource = item.icon
                    const emoji = item.emoji
                    const color = !!item.color ? item.color
                                               : Theme.palette.userCustomizationColors[item.colorId]
                    metadata.set(item.itemId, { text, imageSource, emoji, color })
                }

                d.metadata = metadata
            }

            onModelChanged: revisionChanged()
        }

        property var metadata: new Map()

        function get(key, role) {
            const item = metadata.get(key)
            return !!item ? item[role] : ""
        }
    }

    proxyRoles: [
        ExpressionRole {
            name: "text"
            expression: d.get(model.key, name)
        },
        ExpressionRole {
            name: "imageSource"
            expression: d.get(model.key, name)
        },
        ExpressionRole {
            name: "emoji"
            expression: d.get(model.key, name)
        },
        ExpressionRole {
            name: "color"
            expression: d.get(model.key, name)
        },
        ExpressionRole {
            name: "operator"

            // Direct call for singleton enum is not handled properly by SortFilterProxyModel.
            readonly property int none: OperatorsUtils.Operators.None

            expression: none
        }
    ]
}
