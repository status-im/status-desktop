import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Communities.views

import Storybook
import Models

import SortFilterProxyModel

import utils

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
                anchors.rightMargin: 0

                internalRightPadding: 50

                model: filteredTokensModel
                isOwner: true
                isAdmin: false

                onItemClicked: tokenKey =>
                               logs.logEvent("MintedTokensView::itemClicked",
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

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A479136&t=zs22ORYUVDYpqubQ-1
