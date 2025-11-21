import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Popups.Dialog

StatusDialog {
    id: root

    property int chainId
    property string iconUrl
    property string chainName
    
    header: StatusDialogHeader {
        headline.title: qsTr("Disable %1 network").arg(chainName)
        leftComponent: StatusRoundedImage {
            image.source: Assets.svg(root.iconUrl)
            width: 40
            height: 40
        }
        actions.closeButton.onClicked: root.close()
    }

    contentItem: StatusBaseText {
        wrapMode: Text.Wrap
        text: qsTr("Balances stored on this network will not be visible in the Wallet. Your funds will be safe and you can always enable the network again.")
    }
    okButtonText: qsTr("Disable %1").arg(chainName)
    destroyOnClose: true
}