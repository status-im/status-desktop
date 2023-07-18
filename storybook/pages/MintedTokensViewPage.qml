import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.views 1.0

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2

import utils 1.0

SplitView {
    Logs { id: logs }

    MintedTokensModel {
        id: allTokensModel
    }

    SortFilterProxyModel {
        id: filteredTokensModel

        sourceModel: allTokensModel

        filters: [
            ValueFilter {
                enabled: !allTokensRadioButton.checked
                roleName: "tokenType"
                value: onlyAssetsRadioButton.checked ? Constants.TokenType.ERC20
                                                     : Constants.TokenType.ERC721
            },
            IndexFilter {
                enabled: nothingRadioButton.checked
                minimumIndex: -1
                maximumIndex: 0
            }

        ]
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            MintedTokensView {
                anchors.fill: parent
                anchors.margins: 50
                model: filteredTokensModel
                isOwner: true
                isAdmin: false

                onItemClicked: logs.logEvent("MintedTokensView::itemClicked",
                                             ["tokenKey"], [tokenKey])
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText

            RowLayout {
                RadioButton {
                    id: allTokensRadioButton

                    text: "Assets and collectibles"
                    checked: true
                }

                RadioButton {
                    id: onlyAssetsRadioButton

                    text: "Only assets"
                }

                RadioButton {
                    text: "Only collectibles"
                }

                RadioButton {
                    id: nothingRadioButton

                    text: "Nothing"
                }
            }
        }
    }
}
