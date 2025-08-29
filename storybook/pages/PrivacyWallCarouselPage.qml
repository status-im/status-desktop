import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import shared.panels

import Storybook

SplitView {
    id: root

    Logs { id: logs }

    PrivacyWallCarousel {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        infoText: qsTr("Enable third-party services for wallet features to work.")

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

        onEnableThirdpartyServicesRequested: logs.logEvent("Enable third party services requested")
        onOpenDiscussPageRequested: logs.logEvent("Open discuss page requested")
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Panels
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=26157-27066&m=dev
