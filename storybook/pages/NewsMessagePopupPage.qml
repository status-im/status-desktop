import QtQuick 2.15
import QtQuick.Controls 2.15

import Storybook 1.0

import shared.popups 1.0

Item {
    Button {
        anchors.centerIn: parent
        text: "Reopen"
        onClicked: popup.open()
    }

    Logs { id: logs }

    QtObject {
        id: notificationMock

        property string id: "1"
        property string title: "Swaps around the corner!"
        property string description: "Status Desktop’s next release brings the app up-to-speed with Status Mobile. That means: SWAPS!"
        property string content: "Status Desktop’s next release brings the app up-to-speed with Status Mobile. That means: SWAPS! Now you can trade Ethereum, Arbitrum and Optimism tokens directly in-app. Status leverages Paraswap so you always benefit from the best prices and fastest settlements!"
        property string link: "https://status.app/"
        property string linkLabel: "Read our blog post"
        property string imageUrl: "https://picsum.photos/438/300"
        property double timestamp: Date.now()
        property double previousTimestamp: 0
        property bool read: false
        property bool dismissed: false
        property bool accepted: false
    }

    NewsMessagePopup {
        id: popup
        visible: true
        notification: notificationMock
        onLinkClicked: logs.logEvent("NewsMessagesPopup::onLinkClicked")
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}

// category: Popups
// status: good
