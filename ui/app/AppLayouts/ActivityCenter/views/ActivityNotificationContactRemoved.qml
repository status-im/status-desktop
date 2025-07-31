import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

import shared
import shared.panels
import utils

import "../panels"
import "../popups"

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
