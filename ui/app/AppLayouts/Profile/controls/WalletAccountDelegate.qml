import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import utils 1.0

StatusListItem {
    signal goToAccountView()

    property var account
    
    title: account.name
    subTitle: account.address
    icon.color: account.color
    icon.emoji: account.emoji
    icon.name: !account.emoji ? "filled-account": ""
    icon.letterSize: Style.current.secondaryTextFontSize
    icon.isLetterIdenticon: !!account.emoji
    icon.background.color: Theme.palette.indirectColor1
    width: parent.width
    components: [
        StatusIcon {
            icon: "chevron-down"
            rotation: 270
            color: Theme.palette.baseColor1
        }
    ]

    onClicked: {
        goToAccountView()
    }
}
