import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.popups.walletconnect 1.0

SplitView {
    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        RoundImageWithBadge {
            id: roundImageWithBadge
            
            width: parent.width
            height: width
            imageUrl: addressField.text
            badgeIcon: badgeField.text
            fallbackIcon: fallbackIconField.text
        }
    }

    Pane {
        id: controlsPane
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300
        ColumnLayout {
            Label { text: "Image url" }
            TextField {
                id: addressField
                text: "https://picsum.photos/200/200"
                Layout.fillWidth: true
            }
            Label { text: "Badge name" }
            TextField {
                id: badgeField
                text: "walletConnect"
                Layout.fillWidth: true
            }
            Label { text: "Fallback icon name" }
            TextField {
                id: fallbackIconField
                text: "dapp"
                Layout.fillWidth: true
            }
        }
    }
}

// category: Components

// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=481-160233&t=xyix3QX5I3jxrDir-0