import QtQml 2.15
import SortFilterProxyModel 0.2

import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ 0.1

import utils 1.0

SortFilterProxyModel {
    id: root
    
    property var selectedChannels
    property var allChannels

    property var jointModel: LeftJoinModel {
        readonly property var channelsModelAlignedKey: SortFilterProxyModel {
            sourceModel: root.allChannels
            proxyRoles: [
                FastExpressionRole {
                    name: "key"
                    expression: model.itemId ?? ""
                    expectedRoles: ["itemId"]
                }
            ]
        }
        leftModel: root.selectedChannels
        rightModel: channelsModelAlignedKey
        joinRole: "key"
    }

    sourceModel: jointModel

    proxyRoles: [
        FastExpressionRole {
            name: "text"
            expression: "#" + model.name
            expectedRoles: ["name"]
        },
        FastExpressionRole {
            name: "imageSource"
            expression: model.icon
            expectedRoles: ["icon"]
        },
        FastExpressionRole {
            name: "operator"

            // Direct call for singleton enum is not handled properly by SortFilterProxyModel.
            readonly property int none: OperatorsUtils.Operators.None

            expression: none
            expectedRoles: []
        }
    ]
}
