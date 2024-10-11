import QtQuick 2.14

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import AppLayouts.Wallet 1.0

import utils 1.0

StatusListItem {
    id: root
    
    property var account
    property int totalCount: 0
    property bool nextIconVisible: true

    signal goToAccountView()

    objectName: account.name
    title: account.name
    subTitle: WalletUtils.addressToDisplay(account.address, true, sensor.containsMouse)
    asset.color: !!account.colorId ? Utils.getColorForId(account.colorId): ""
    asset.emoji: account.emoji
    asset.name: !account.emoji ? "filled-account": ""
    asset.letterSize: 14
    asset.isLetterIdenticon: !!account.emoji
    asset.bgColor: Theme.palette.primaryColor3
    asset.width: 40
    asset.height: 40
    
    components: StatusIcon {
        icon: "next"
        color: Theme.palette.baseColor1
        visible: root.nextIconVisible
    }

    onClicked: goToAccountView()

    // This is used to give the first and last delgate rounded corners
    Rectangle {
        visible: totalCount > 1
        readonly property bool isLastOrFirstItem: index === 0 || index === (totalCount-1)
        width: parent.width
        height: isLastOrFirstItem? parent.height/2 : parent.height
        anchors.top: !isLastOrFirstItem || index === (totalCount-1) ? parent.top: undefined
        anchors.bottom: index === 0 ? parent.bottom: undefined
        color: parent.color
        z: parent.z - 10
    }
}
