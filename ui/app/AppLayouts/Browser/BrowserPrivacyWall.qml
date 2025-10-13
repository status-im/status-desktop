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

        infoText: qsTr("Enable third-party services for browser features to work.")
        model: ListModel {
            ListElement {
                primary: qsTr("Dapp browser")
                secondary: qsTr("Browse decentralized apps")
                image: "browser/placeholders/browser"
            }
        }

        onEnableThirdpartyServicesRequested: root.openThirdpartyServicesInfoPopupRequested()
        onOpenDiscussPageRequested: root.openDiscussPageRequested()
    }
}
