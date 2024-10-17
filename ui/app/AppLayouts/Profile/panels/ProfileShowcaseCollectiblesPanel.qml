import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Profile.controls 1.0
import AppLayouts.Wallet.controls 1.0

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
