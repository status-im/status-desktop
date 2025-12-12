import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils
import shared.controls

Column {
    id: root

    property string addressText: ""
    property string addressColor: Theme.palette.directColor1
    property var addressDetailsItem
    property bool addressResolved: true
    property bool displayDetails: true
    property bool displayCopyButton: true
    property bool alreadyCreatedAccountIsAnError: true

    spacing: Theme.halfPadding

    StatusBaseText {
        text: root.addressText
    }

    StatusInput {
        width: parent.width
        text: root.addressDetailsItem.address
        input.edit.enabled: false
        input.edit.color: root.addressColor
        input.background.color: "transparent"
        input.background.border.color: Theme.palette.baseColor2
        input.rightComponent: CopyButton {
            visible: root.displayCopyButton
            textToCopy: root.addressDetailsItem.address
        }
    }

    AddressDetails {
        width: parent.width
        visible: root.displayDetails
        addressDetailsItem: root.addressDetailsItem
        defaultMessage: ""
        defaultMessageCondition: !root.addressResolved
        alreadyCreatedAccountIsAnError: root.alreadyCreatedAccountIsAnError
    }
}
