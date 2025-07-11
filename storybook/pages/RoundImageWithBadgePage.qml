import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import shared.popups.walletconnect

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
            badgeSize: badgeSizeSlider.value
            badgeMargin: badgeMarginSlider.value
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
                text: "https://random.imagecdn.app/20/20"
                Layout.fillWidth: true
            }
            Label { text: "Fallback icon name" }
            TextField {
                id: fallbackIconField
                text: "dapp"
                Layout.fillWidth: true
            }
            Label {
                text: "Badge size"
            }
            Slider {
                id: badgeSizeSlider
                from: 0
                to: roundImageWithBadge.width
                value: roundImageWithBadge.badgeSize
            }
            Label {
                text: "Badge margin"
            }
            Slider {
                id: badgeMarginSlider
                from: 0
                to: roundImageWithBadge.width
                value: roundImageWithBadge.badgeMargin
            }
        }
    }
}

// category: Components

// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=481-160233&t=xyix3QX5I3jxrDir-0