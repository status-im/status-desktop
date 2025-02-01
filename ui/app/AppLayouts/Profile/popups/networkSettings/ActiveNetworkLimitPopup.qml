import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

StatusDialog {    
    title: qsTr("Network limit reached")
    contentItem: StatusBaseText {
        wrapMode: Text.Wrap
        text: qsTr("A maximum of %1 networks can be enabled simultaneously. Disable one of the networks to enable this one.").arg(Constants.maxActiveNetworks)
    }
    okButtonText: qsTr("Close")
    destroyOnClose: true
}