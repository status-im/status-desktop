import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import StatusQ.Controls 0.1

import shared.popups 1.0

SplitView {
    Logs { id: logs }
    orientation: Qt.Vertical
    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            anchors.centerIn: parent
            text: "Reopen"
            onClicked: popup.open()
        }


        QtObject {
            id: notificationMock

            property string id: "1"
            property string title: "Swaps around the corner!"
            property string description: "Status Desktop's next release brings the app up-to-speed with Status Mobile. That means: SWAPS!"
            property string content: "Status Desktop's next release brings the app up-to-speed with Status Mobile. That means: SWAPS! Now you can trade Ethereum, Arbitrum and Optimism tokens directly in-app. Status leverages Paraswap so you always benefit from the best prices and fastest settlements!"
            property string link: "https://status.app/"
            property string linkLabel: linkLabelInput.text
            property string imageUrl: hasImage.checked ? "https://picsum.photos/438/300" : ""
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
    }
   
    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        RowLayout {
            spacing: 4

            CheckBox {
                id: hasImage
                text: "Has Image"
                checked: true
            }

            StatusInput {
                id: linkLabelInput
                label: "linkLabel"
                text: "Read our blog post"
            }
        }
    }
}

// category: Popups
// status: good
