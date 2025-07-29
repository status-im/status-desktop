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

    contentHeaderAreaText: qsTr("Removed you as a contact")
    ctaComponent: StatusLinkText {
        visible: root.contactDetails && !root.contactDetails.added && !root.contactDetails.isContactRequestReceived
        text: qsTr("Send Contact Request")
        color: Theme.palette.primaryColor1
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Normal
        onClicked: Global.openContactRequestPopup(root.contactId, null)
    }
}
