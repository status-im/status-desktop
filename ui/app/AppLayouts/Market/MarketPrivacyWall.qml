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

        infoText: qsTr("Enable third-party services for market features to work.")
        model: ListModel {
            ListElement {
                primary: qsTr("Real-time token data")
                secondary: qsTr("Stay updated with live prices and trading volumes.")
                image: "market/tradeCenter"
            }
            ListElement {
                primary: qsTr("Swap straight from the market")
                secondary: qsTr("Easy swaps to any token from leaderboard")
                image: "market/swap"
            }
        }

        onEnableThirdpartyServicesRequested: root.openThirdpartyServicesInfoPopupRequested()
        onOpenDiscussPageRequested: root.openDiscussPageRequested()
    }
}
