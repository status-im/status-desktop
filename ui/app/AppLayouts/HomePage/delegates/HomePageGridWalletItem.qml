import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import utils

HomePageGridItem {
    id: root

    property string currencyBalance
    property string walletType

    sectionType: Constants.appSection.wallet
    subtitle: SQUtils.Utils.elideAndFormatWalletAddress(root.itemId)

    background: Rectangle {
        color: hovered ? Qt.lighter(Theme.palette.baseColor4, 1.5) : Theme.palette.baseColor4
        Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
        radius: Theme.padding

        opacity: pressed || down ? Theme.pressedOpacity : enabled ? 1 : Theme.disabledOpacity
        Behavior on opacity { NumberAnimation { duration: Theme.AnimationDuration.Fast } }
    }

    iconLoaderComponent: StatusLetterIdenticon {
        color: root.icon.color
        emoji: root.icon.name
        radius: Theme.padding
    }

    bottomRowComponent: RowLayout {
        width: root.availableWidth
        StatusBaseText {
            Layout.fillWidth: true
            text: root.currencyBalance
            font.pixelSize: Theme.tertiaryTextFontSize
            font.weight: Font.Medium
        }
        StatusIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            icon: {
                if (root.walletType === Constants.watchWalletType)
                    return "show"
                if (root.walletType === Constants.keyWalletType)
                    return "keycard"
                return ""
            }
            color: Theme.palette.directColor1
            visible: !!icon
        }
    }
}
