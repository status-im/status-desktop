import QtQuick
import QtQuick.Layouts

import StatusQ.Layout

import shared.panels
import utils

StatusSectionLayout {
    id: root

    signal openDiscussPageRequested()
    signal openThirdpartyServicesInfoPopupRequested()

    centerPanel: PrivacyWallCarousel {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: ListModel {
            ListElement {
                primary: qsTr("Portfolio view for your tokens")
                secondary: qsTr("Use multi-chain, multi-account, and fully self-custodial wallet")
                image: "wallet/placeholders/mainView"
            }
            ListElement {
                primary: qsTr("Fast & easy token swaps")
                secondary: qsTr("Access wide token coverage and the best prices across top DEXes")
                image: "wallet/placeholders/swapView"
            }
            ListElement {
                header: qsTr("Organize collectibles your way")
                secondary: qsTr("Search, filter, and sort your collectibles exactly how you want")
                image: "wallet/placeholders/collectiblesView"
            }
            ListElement {
                primary: qsTr("Multiple ways to buy tokens")
                secondary: qsTr("Pay with cards, bank transfers, Apple/Google Pay, SEPA, and 9+ options")
                image: "wallet/placeholders/buyView"
            }
        }

        onEnableThirdpartyServicesRequested: root.openThirdpartyServicesInfoPopupRequested()
        onOpenDiscussPageRequested: root.openDiscussPageRequested()
    }
}
