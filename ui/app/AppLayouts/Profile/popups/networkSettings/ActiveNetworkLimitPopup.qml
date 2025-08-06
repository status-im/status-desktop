import QtQuick

import StatusQ.Core
import StatusQ.Popups.Dialog

import utils

StatusDialog {    
    title: qsTr("Network limit reached")
    contentItem: StatusBaseText {
        wrapMode: Text.Wrap
        text: qsTr("A maximum of %1 networks can be enabled simultaneously. Disable one of the networks to enable this one.").arg(Constants.maxActiveNetworks)
    }
    okButtonText: qsTr("Close")
    destroyOnClose: true
}
