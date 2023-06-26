import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Communities.views 1.0

import Storybook 1.0
import Models 1.0

import utils 1.0

SplitView {

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            MintedTokensView {
                anchors.fill: parent
                anchors.margins: 50
                model: MintedTokensModel.mintedTokensModel
                onItemClicked: logs.logEvent("MintedTokensView::itemClicked --> " + tokenKey)
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText

            RowLayout {
                RadioButton {
                   text: "Assets and collectibles"
                   checked: true
                   onCheckedChanged: if(checked) MintedTokensModel.buildMintedTokensModel(true, true)
                }

                RadioButton {
                   text: "Only assets"
                   onCheckedChanged: if(checked) MintedTokensModel.buildMintedTokensModel(true, false)
                }

                RadioButton {
                   text: "Only collectibles"
                   onCheckedChanged: if(checked) MintedTokensModel.buildMintedTokensModel(false, true)
                }
            }
        }
    }

}
