import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0
import shared.stores 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: CommunityTokensStore {}
    }

    readonly property string currentWallet: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"

    ListModel {
        id: emptyModel
    }

    ListModel {
        id: accountsModel

        ListElement {
            name: "My Status Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
            colorId: "primary"
            emoji: "🇨🇿"
            walletType: ""
        }
        ListElement {
            name: "testing (no emoji, colored, seed)"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
            colorId: ""
            emoji: ""
            walletType: "seed"
        }
        ListElement {
            name: "My Bro's Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            colorId: "orange"
            emoji: "🇸🇰"
            walletType: "watch"
        }
    }

    ListModel {
        id: inShowcaseAccountsModel

        property int hiddenCount: emptyModelChecker.checked ? 0 : accountsModel.count - count

        signal baseModelFilterConditionsMayHaveChanged()

        function setVisibilityByIndex(index, visibility) {
            if (visibility === Constants.ShowcaseVisibility.NoOne) {
                remove(index)
            } else {
                 get(index).showcaseVisibility = visibility
            }
        }

        function setVisibility(address, visibility) {
            for (let i = 0; i < count; ++i) {
                if (get(i).address === address) {
                    setVisibilityByIndex(i, visibility)
                }
            }
        }

        function hasItemInShowcase(address) {
            for (let i = 0; i < count; ++i) {
                if (get(i).address === address) {
                    return true
                }
            }
            return false
        }

        function upsertItemJson(item) {
            append(JSON.parse(item))
        }
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        ProfileShowcaseAccountsPanel {
            id: showcasePanel
            width: 500
            baseModel: emptyModelChecker.checked ? emptyModel : accountsModel
            showcaseModel: inShowcaseAccountsModel
            currentWallet: root.currentWallet
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Button {
                text: "Reset (clear settings)"
                onClicked: showcasePanel.reset()
            }

            CheckBox {
                id: emptyModelChecker

                text: "Empty model"
                checked: false

                onClicked: showcasePanel.reset()
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?type=design&node-id=2460%3A40333&mode=design&t=Zj3tcx9uj05XHYti-1
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?type=design&node-id=2460%3A40362&mode=design&t=Zj3tcx9uj05XHYti-1
