import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    destroyOnClose: true
    title: qsTr("What are community assets?")
    standardButtons: Dialog.Ok
    width: 520
    contentItem: StatusBaseText {
        wrapMode: Text.Wrap
        text: qsTr("Community assets are assets that have been minted by a community. As these assets cannot be verified, always double check their origin and validity before interacting with them. If in doubt, ask a trusted member or admin of the relevant community.")
    }
}
