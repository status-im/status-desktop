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
    objectName: account.name
    asset.color: account.color
    asset.emoji: account.emoji
    asset.name: !account.emoji ? "filled-account": ""
    asset.letterSize: 14
    asset.isLetterIdenticon: !!account.emoji
    asset.bgColor: Theme.palette.primaryColor3
    asset.width: 40
    asset.height: 40
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
