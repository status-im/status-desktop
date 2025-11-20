import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Components

import AppLayouts.Communities.views

import Storybook
import Models

import utils

SplitView {

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            EditCommunityTokenView {
                anchors.fill: parent
                anchors.margins: 50
                anchors.rightMargin: 0

                preferredContentWidth: 560
                internalRightPadding: 50

                isAssetView: isAssetBox.checked
                accounts: WalletAccountsModel {}
                tokensModel: MintedTokensModel {}
                referenceTokenGroupsModel: ListModel {
                    ListElement {
                        name: "eth"
                        symbol: "ETH"
                    }
                    ListElement {
                        name: "dai"
                        symbol: "DAI"
                    }
                    ListElement {
                        name: "snt"
                        symbol: "SNT"
                    }
                }
                onPreviewClicked: logs.logEvent("EditCommunityTokenView::previewClicked")
            }
        }


        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText

            CheckBox {
                id: isAssetBox
                text: "Is Assets View?"
                checked: false
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A480877&t=Qo2FwPRxvSxbluqB-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=26601%3A518245&t=Qo2FwPRxvSxbluqB-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22721%3A498811&t=Qo2FwPRxvSxbluqB-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29384%3A563759&t=g40TADKO0p93G4r0-1
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=29423%3A593514&t=g40TADKO0p93G4r0-1
