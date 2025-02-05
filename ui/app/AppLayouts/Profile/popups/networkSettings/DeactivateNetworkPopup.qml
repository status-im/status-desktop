import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property int chainId
    property string iconUrl
    property string chainName
    
    header: StatusDialogHeader {
        headline.title: qsTr("Disable %1 network").arg(chainName)
        leftComponent: StatusRoundedImage {
            image.source: Theme.svg(root.iconUrl)
            width: 40
            height: 40
        }
    }

    contentItem: StatusBaseText {
        wrapMode: Text.Wrap
        text: qsTr("Balances stored on this network will not be visible in the Wallet. Your funds will be safe and you can always enable the network again.")
    }
    okButtonText: qsTr("Disable %1").arg(chainName)
    destroyOnClose: true
}