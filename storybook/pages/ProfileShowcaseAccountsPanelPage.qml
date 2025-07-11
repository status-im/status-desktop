import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils as CoreUtils

import AppLayouts.Profile.panels
import shared.stores

import utils

import Storybook
import Models

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    readonly property string currentWallet: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"

    ListModel {
        id: hiddenModelItem
        ListElement {
            name: "My Status Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
            showcaseKey: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
            colorId: "primary"
            emoji: "🇨🇿"
            walletType: ""
            showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        }
        ListElement {
            name: "testing (no emoji, colored, seed)"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
            showcaseKey: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
            colorId: ""
            emoji: ""
            walletType: "seed"
            showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        }
        ListElement {
            name: "My Bro's Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            showcaseKey: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            colorId: "orange"
            emoji: "🇸🇰"
            walletType: "watch"
            showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        }
    }

    ListModel {
        id: inShowcaseModelItem

        ListElement {
            name: "My Status Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
            showcaseKey: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
            colorId: "primary"
            emoji: "🇨🇿"
            walletType: ""
            showcaseVisibility: Constants.ShowcaseVisibility.Everyone
            showcasePosition: 0
        }
        ListElement {
            name: "testing (no emoji, colored, seed)"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
            showcaseKey: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
            colorId: ""
            emoji: ""
            walletType: "seed"
            showcaseVisibility: Constants.ShowcaseVisibility.Everyone
            showcasePosition: 1
        }
        ListElement {
            name: "My Bro's Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            showcaseKey: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            colorId: "orange"
            emoji: "🇸🇰"
            walletType: "watch"
            showcaseVisibility: Constants.ShowcaseVisibility.Everyone
            showcasePosition: 2
        }
    }

    ListModel {
        id: emptyModel
    }

    ProfileShowcaseAccountsPanel {
        id: showcasePanel
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        inShowcaseModel: emptyModelChecker.checked ? emptyModel : inShowcaseModelItem
        hiddenModel: emptyModelChecker.checked ? emptyModel : hiddenModelItem
        currentWallet: root.currentWallet
        showcaseLimit: 5
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Label {
                text: "ⓘ Showcase interaction implemented in ProfileShowcasePanelPage"
            }

            CheckBox {
                id: emptyModelChecker

                text: "Empty model"
                checked: false
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?type=design&node-id=2460%3A40333&mode=design&t=Zj3tcx9uj05XHYti-1
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?type=design&node-id=2460%3A40362&mode=design&t=Zj3tcx9uj05XHYti-1
