import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0

Column {
    id: root

    property string addressText: ""
    property string addressColor: Theme.palette.directColor1
    property var addressDetailsItem
    property bool addressResolved: true
    property bool displayDetails: true
    property bool displayCopyButton: true
    property bool alreadyCreatedAccountIsAnError: true

    spacing: Style.current.halfPadding

    StatusBaseText {
        text: root.addressText
        font.pixelSize: Constants.addAccountPopup.labelFontSize1
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
