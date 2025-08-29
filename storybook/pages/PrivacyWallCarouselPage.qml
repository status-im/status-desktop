import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import shared.panels

SplitView {
    id: root

    PrivacyWallCarousel {
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
                primary: qsTr("Organize collectibles your way")
                secondary: qsTr("Search, filter, and sort your collectibles exactly how you want")
                image: "wallet/placeholders/collectiblesView"
            }
            ListElement {
                primary: qsTr("Multiple ways to buy tokens")
                secondary: qsTr("Pay with cards, bank transfers, Apple/Google Pay, SEPA, and 9+ options")
                image: "wallet/placeholders/buyView"
            }
        }

        onEnableThirdpartyServicesRequested: console.warn("Enable third party services requested")
        onOpenDiscussPageRequested: console.warn("Open discuss page requested")
    }
}

// category: Panels
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=26157-27066&m=dev
