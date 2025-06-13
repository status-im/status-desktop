import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0
import shared.stores 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

import StatusQ 0.1

import QtModelsToolkit 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    ListModel {
        id: hiddenModelItem
        readonly property var data: [
            {
                uid: "1234",
                showcaseKey: "1234",
                name: "SNTT",
                collectionName: "Super Nitro Toluen (with pink bg)",
                backgroundColor: "pink",
                imageUrl: ModelsData.collectibles.custom,
                isLoading: false,
                communityId: "ddls",
                showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            },
            {
                uid: "34545656768",
                showcaseKey: "3454565676",
                name: "Kitty 3",
                collectionName: "Kitties",
                backgroundColor: "",
                imageUrl: ModelsData.collectibles.kitty1Big,
                isLoading: false,
                showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            },
            {
                uid: "123456",
                showcaseKey: "12345",
                name: "Kitty 4",
                collectionName: "",
                backgroundColor: "",
                imageUrl: ModelsData.collectibles.kitty2Big,
                isLoading: false,
                communityId: "sox",
                showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            },
            {
                uid: "12345645459537432",
                showcaseKey: "123456454595374",
                name: "",
                collectionName: "Super Kitties",
                backgroundColor: "oink",
                imageUrl: ModelsData.collectibles.kitty3Big,
                isLoading: false,
                communityId: "ast",
                showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            },
            {
                uid: "6912",
                showcaseKey: "6912",
                name: "KILLABEAR",
                collectionName: "KILLABEARS",
                backgroundColor: "#807c56",
                imageUrl: "https://assets.killabears.com/content/killabears/img/691-e81f892696a8ae700e0dbc62eb072060679a2046d1ef5eb2671bdb1fad1f68e3.png",
                isLoading: true,
                showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                maxVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            },
            {
                uid: "8876",
                showcaseKey: "8876",
                name: "AIORBIT",
                description: "",
                collectionName: "AIORBIT (Animated SVG)",
                backgroundColor: "",
                imageUrl: "https://dl.openseauserdata.com/cache/originImage/files/8b14ef530b28853445c27d6693c4e805.svg",
                isLoading: false,
                showcaseVisibility: Constants.ShowcaseVisibility.NoOne,
                maxVisibility: Constants.ShowcaseVisibility.Contacts
            }
        ]
        Component.onCompleted: append(data)
    }

    ListModel {
        id: inShowcaseModelItem

        readonly property var data: [
            {
                uid: "123",
                showcaseKey: "1234",
                name: "SNT",
                collectionName: "Super Nitro Toluen (with pink bg)",
                backgroundColor: "pink",
                imageUrl: ModelsData.collectibles.custom,
                isLoading: false,
                communityId: "ddls",
                showcaseVisibility: Constants.ShowcaseVisibility.Contacts,
                maxVisibility: Constants.ShowcaseVisibility.Contacts
            },
            {
                uid: "34545656768",
                showcaseKey: "3454565676",
                name: "Kitty 1",
                collectionName: "Kitties",
                backgroundColor: "",
                imageUrl: ModelsData.collectibles.kitty1Big,
                isLoading: false,
                showcaseVisibility: Constants.ShowcaseVisibility.Contacts,
                maxVisibility: Constants.ShowcaseVisibility.Contacts
            },
            {
                uid: "123456",
                showcaseKey: "12345",
                name: "Kitty 2",
                collectionName: "",
                backgroundColor: "",
                imageUrl: ModelsData.collectibles.kitty2Big,
                isLoading: false,
                communityId: "sox",
                showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts,
                maxVisibility: Constants.ShowcaseVisibility.Contacts
            },
            {
                uid: "12345645459537432",
                showcaseKey: "123456454595374",
                name: "",
                collectionName: "Super Kitties",
                backgroundColor: "oink",
                imageUrl: ModelsData.collectibles.kitty3Big,
                isLoading: false,
                communityId: "ast",
                showcaseVisibility: Constants.ShowcaseVisibility.Everyone,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            },
            {
                uid: "691",
                showcaseKey: "6912",
                name: "KILLABEAR",
                collectionName: "KILLABEARS",
                backgroundColor: "#807c56",
                imageUrl: "https://assets.killabears.com/content/killabears/img/691-e81f892696a8ae700e0dbc62eb072060679a2046d1ef5eb2671bdb1fad1f68e3.png",
                isLoading: true,
                showcaseVisibility: Constants.ShowcaseVisibility.Everyone,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            },
            {
                uid: "8876",
                showcaseKey: "8876",
                name: "AIORBIT",
                description: "",
                collectionName: "AIORBIT (Animated SVG)",
                backgroundColor: "",
                imageUrl: "https://dl.openseauserdata.com/cache/originImage/files/8b14ef530b28853445c27d6693c4e805.svg",
                isLoading: false,
                showcaseVisibility: Constants.ShowcaseVisibility.Everyone,
                maxVisibility: Constants.ShowcaseVisibility.Everyone
            }
        ]
        Component.onCompleted: append(data)
    }

    ListModel {
        id: communityModel

        readonly property var data: [
            {
                communityId: "ddls",
                communityName: "Doodles",
                communityImage: ModelsData.collectibles.doodles
            },
            {
                communityId: "sox",
                communityName: "Socks",
                communityImage: ModelsData.icons.socks
            },
            {
                communityId: "ast",
                communityName: "Astafarians",
                communityImage: ModelsData.icons.dribble
            }
        ]
        Component.onCompleted: append(data)
    }

    LeftJoinModel {
        id: joinedInShowcase

        leftModel: inShowcaseModelItem
        rightModel: communityModel

        joinRole: "communityId"
    }

    ListModel {
        id: emptyModelItem
    }

    LeftJoinModel {
        id: joinedHiddenModel

        leftModel: hiddenModelItem
        rightModel: communityModel

        joinRole: "communityId"
    }

    ProfileShowcaseCollectiblesPanel {
        id: showcasePanel
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        inShowcaseModel: emptyModelChecker.checked ? emptyModelItem : joinedInShowcase
        hiddenModel: emptyModelChecker.checked ? emptyModelItem : joinedHiddenModel
        showcaseLimit: 8

        addAccountsButtonVisible: !hasAllAccountsChecker.checked

        onNavigateToAccountsTab: logs.logEvent("ProfileShowcaseCollectiblesPanel::onNavigateToAccountsTab")
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
                id: hasAllAccountsChecker

                text: "Has the user already shared all of their accounts"
                checked: true
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

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-235560&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14729-235696&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14729-237604&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/%F0%9F%91%A4-Profile-%7C-Desktop?type=design&node-id=2460%3A37407&mode=design&t=IMh6iN4JPD7OQbJI-1
