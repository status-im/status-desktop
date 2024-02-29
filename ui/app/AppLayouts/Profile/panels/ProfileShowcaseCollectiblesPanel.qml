import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    required property bool addAccountsButtonVisible

    signal navigateToAccountsTab()

    emptyInShowcasePlaceholderText: qsTr("Collectibles here will show on your profile")
    emptyHiddenPlaceholderText: qsTr("Collectibles here will be hidden from your profile")

    additionalFooterComponent: root.addAccountsButtonVisible ? addMoreAccountsComponent : null

    delegate: ProfileShowcasePanelDelegate {
        title: !!model ? `${model.name}` || `#${model.id}` : ""
        secondaryTitle: !!model && !!model.collectionName ? model.collectionName : ""
        hasImage: !!model && !!model.imageUrl

        icon.source: hasImage ? model.imageUrl : ""
        bgRadius: Style.current.radius
        assetBgColor: !!model && !!model.backgroundColor ? model.backgroundColor : "transparent"

        tag.visible: model && !!model.communityId
        tag.text: model && !!model.communityName ? model.communityName : ""
        tag.asset.name: model && !!model.communityImage ? model.communityImage : ""
        tag.loading: model && !!model.communityImageLoading ? model.communityImageLoading : false
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
