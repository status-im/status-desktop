import QtQuick
import QtQuick.Controls

import StatusQ.Core

import AppLayouts.stores as AppLayoutsStores
import AppLayouts.Profile.views
import AppLayouts.Wallet.stores
import AppLayouts.Profile.stores
import mainui
import utils

import Storybook
import Models
import shared.stores as SharedStores

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    readonly property WalletAssetsStore walletAssetStore: WalletAssetsStore {
        assetsWithFilteredBalances: walletAssetStore.groupedAccountsAssetsModel
    }

    readonly property var currencyStore: SharedStores.CurrenciesStore {}

    Popups {
        popupParent: root
        sharedRootStore: SharedStores.RootStore {}
        rootStore: AppLayoutsStores.RootStore
        communityTokensStore: SharedStores.CommunityTokensStore {}
        networksStore: SharedStores.NetworksStore {}
    }

    ListModel {
        id: emptyModel
    }

    CommunitiesModel {
        id: communitiesModel
    }

    CommunitiesView {
        SplitView.fillWidth: true
        SplitView.preferredHeight: 400

        contentWidth: 664
        profileSectionStore: ProfileSectionStore {
            property var communitiesProfileModule: QtObject {
                function setCommunityMuted(communityId, mutedType) {
                    logs.logEvent("profileSectionStore::communitiesProfileModule::setCommunityMuted", ["communityId", "mutedType"], arguments)
                }
                function leaveCommunity(communityId) {
                    logs.logEvent("profileSectionStore::communitiesProfileModule::leaveCommunity", ["communityId"], arguments)
                }
            }
            readonly property var communitiesList: ctrlEmptyView.checked ? emptyModel : communitiesModel
        }
        rootStore: AppLayoutsStores.RootStore {
            function isMyCommunityRequestPending(communityId) {
                return communityId === "0x0006"
            }
            function cancelPendingRequest(communityId) {
                logs.logEvent("rootStore::cancelPendingRequest", ["communityId"], arguments)
            }
            function setActiveCommunity(communityId) {
                logs.logEvent("rootStore::setActiveCommunity", ["communityId"], arguments)
            }
        }
        currencyStore: currencyStore
        walletAssetsStore: walletAssetsStore
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Switch {
            id: ctrlEmptyView
            text: "No communities"
        }
    }
}

// category: Views
// status: good
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=16089-387522&t=HRT9BmZXnl7Lt55Q-0
