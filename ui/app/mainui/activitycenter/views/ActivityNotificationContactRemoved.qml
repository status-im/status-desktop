import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"
import "../popups"
import "../stores"

ActivityNotificationMessage {
    id: root

    messageSubheaderComponent: StatusBaseText {
        text: qsTr("Removed you as a contact")
        font.italic: true
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.baseColor1
    }

    ctaComponent: StatusFlatButton {
        enabled: root.contactDetails && !root.contactDetails.added && !root.contactDetails.isContactRequestReceived
        size: StatusBaseButton.Size.Small
        text: qsTr("Send Contact Request")
        onClicked: Global.openContactRequestPopup(root.contactId, null)
    }
}
