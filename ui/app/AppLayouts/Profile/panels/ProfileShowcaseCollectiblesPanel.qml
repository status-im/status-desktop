import QtQuick
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils
import shared.panels

import AppLayouts.Profile.controls
import AppLayouts.Wallet.controls

ProfileShowcasePanel {
    id: root

    required property bool addAccountsButtonVisible

    signal navigateToAccountsTab()

    emptyInShowcasePlaceholderText: qsTr("Collectibles here will show on your profile")
    emptyHiddenPlaceholderText: qsTr("Collectibles here will be hidden from your profile")
    emptySearchPlaceholderText: qsTr("No collectibles matching search")
    searchPlaceholderText: qsTr("Search collectible name, number, collection or community")
    additionalFooterComponent: root.addAccountsButtonVisible ? addMoreAccountsComponent : null

    delegate: ProfileShowcasePanelDelegate {
        id: delegate
        title: !!model ? `${model.name}` || `#${model.id}` : ""
        secondaryTitle: !!model && !!model.collectionName ? model.collectionName : ""
        hasImage: !!model && !!model.imageUrl

        icon.source: hasImage ? model.imageUrl : ""
        bgRadius: Theme.radius
        assetBgColor: !!model && !!model.backgroundColor ? model.backgroundColor : "transparent"

        actionComponent: model && !!model.communityId ? communityTokenTagComponent : null
        showcaseMaxVisibility: model ? model.maxVisibility : Constants.ShowcaseVisibility.Everyone
        onShowcaseMaxVisibilityChanged: {
            if (delegate.showcaseVisibility > delegate.showcaseMaxVisibility) {
               root.setVisibilityRequested(delegate.key, delegate.showcaseMaxVisibility)
            }
        }

        Component {
            id: communityTokenTagComponent
            ManageTokensCommunityTag {
                communityName: model && !!model.communityName ? model.communityName : ""
                communityId: model && !!model.communityId ? model.communityId : ""
                communityImage: model && !!model.communityImage ? model.communityImage : ""
                loading: model && !!model.communityImageLoading ? model.communityImageLoading : false
            }
        }
    }

    filter: FastExpressionFilter {
        readonly property string lowerCaseSearchText: root.searcherText.toLowerCase()
        expression: {
            lowerCaseSearchText
            return (name.toLowerCase().includes(lowerCaseSearchText) ||
                    uid.toLowerCase().includes(lowerCaseSearchText) ||
                    (!!communityName && communityName.toLowerCase().includes(lowerCaseSearchText)) ||
                    (!!collectionName && collectionName.toLowerCase().includes(lowerCaseSearchText)))
        }
        expectedRoles: ["name", "uid", "collectionName", "communityName"]
    }

    Component {
        id: addMoreAccountsComponent

        AddMoreAccountsLink {
            visible: root.addAccountsButtonVisible
            text: qsTr("Don’t see some of your collectibles?")
            onClicked: root.navigateToAccountsTab()
        }
    }
}
