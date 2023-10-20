import QtQuick 2.15
import QtQuick.Controls 2.15

import Storybook 1.0
import Models 1.0
import SortFilterProxyModel 0.2

import StatusQ 0.1

import AppLayouts.Profile.popups 1.0

SplitView {
    id: root

    Logs { id: logs }

    readonly property var sourcesOfTokensModel: SourceOfTokensModel {}
    readonly property var flatTokensModel: FlatTokensModel {}
    readonly property var joinModel: LeftJoinModel {
        leftModel: root.flatTokensModel
        rightModel: NetworksModel.allNetworks

        joinRole: "chainId"
    }
    readonly property var tokensProxyModel: SortFilterProxyModel {
        sourceModel: joinModel

        proxyRoles:  [
            ExpressionRole {
                name: "explorerUrl"
                expression: { return  "https://status.im/" }
            }
        ]
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Instantiator {
                model: SortFilterProxyModel {
                    sourceModel: sourcesOfTokensModel

                    filters: ValueFilter {
                        id: keyFilter

                        roleName: "key"
                        value : uniswapBtn.checked ? "uniswap" : "status"
                    }
                }

                delegate: QtObject {
                    id: delegate

                    required property string name
                    required property string image
                    required property string source
                    required property int updatedAt
                    required property string version
                    required property int tokensCount

                    readonly property TokenListPopup popup: TokenListPopup {
                        parent: root

                        visible: true
                        modal: false
                        closePolicy: Popup.NoAutoClose

                        sourceName: delegate.name
                        sourceImage: delegate.image
                        sourceUrl: delegate.source
                        sourceUpdatedAt: delegate.updatedAt
                        sourceVersion: delegate.version
                        tokensCount: delegate.tokensCount

                        tokensListModel: SortFilterProxyModel {
                            sourceModel: root.tokensProxyModel

                            // Filter by source
                            filters: RegExpFilter {
                                roleName: "sources"
                                pattern: "\;" + keyFilter.value + "\;"
                            }
                        }

                        onLinkClicked: logs.logEvent("TokenListPopup::onLinkClicked --> " + link)
                        onClosed: keyFilter.value = ""
                        Component.onCompleted: open()
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Column {
            spacing: 12

            Label {
                text: "Token List:"
                font.bold: true
            }

            RadioButton {
                id: uniswapBtn

                text: "Uniswap"
                checked: true

                onCheckedChanged: keyFilter.value = "uniswap"
            }

            RadioButton {
                id: statusBtn

                text: "Status"

                onCheckedChanged: keyFilter.value = "status"
            }
        }
    }
}

// category: Popups
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18057%3A239798&mode=design&t=Vnm5GS8EZFLpeRAY-1
