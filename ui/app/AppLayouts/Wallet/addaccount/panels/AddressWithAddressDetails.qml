import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

Column {
    id: root

    property var addressDetailsItem
    property bool addressResolved: true

    spacing: Style.current.halfPadding

    StatusBaseText {
        text: qsTr("Public address of private key")
        font.pixelSize: Constants.addAccountPopup.labelFontSize1
    }

    StatusInput {
        width: parent.width
        input.edit.enabled: false
        text: root.addressDetailsItem.address
        input.background.color: "transparent"
        input.background.border.color: Theme.palette.baseColor2
    }

    AddressDetails {
        width: parent.width
        addressDetailsItem: root.addressDetailsItem
        defaultMessage: ""
        defaultMessageCondition: !root.addressResolved
    }
}
