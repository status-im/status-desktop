import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Popups.Dialog

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
