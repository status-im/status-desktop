import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1


StatusListItem {
    id: root
    
    property var account
    property bool showShevronIcon: true

    signal goToAccountView()
    
    title: account.name
    subTitle: account.address
    icon.color: account.color
    icon.emoji: account.emoji
    icon.name: !account.emoji ? "filled-account": ""
    icon.letterSize: 14
    icon.isLetterIdenticon: !!account.emoji
    icon.background.color: Theme.palette.primaryColor3
    width: parent.width
    
    components: !showShevronIcon ? [] : [ shevronIcon ]

    onClicked: {
        goToAccountView()
    }

    StatusIcon {
        id: shevronIcon
        visible: root.showShevronIcon
        icon: "chevron-down"
        rotation: 270
        color: Theme.palette.baseColor1
    }
}
