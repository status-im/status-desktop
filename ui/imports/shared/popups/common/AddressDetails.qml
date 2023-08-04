import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Row {
    id: root

    property var addressDetailsItem
    property bool defaultMessageCondition: true
    property string defaultMessage: ""
    property bool alreadyCreatedAccountIsAnError: true

    StatusIcon {
        id: icon
        visible: root.addressDetailsItem &&
                 root.addressDetailsItem.loaded &&
                 root.addressDetailsItem.address !== "" &&
                 root.addressDetailsItem.hasActivity
        width: 20
        height: 20
        icon: "flash"
        color: Theme.palette.successColor1
    }

    StatusBaseText {
        width: icon.visible? parent.width - icon.width : parent.width
        font.pixelSize: Constants.addAccountPopup.labelFontSize2
        wrapMode: Text.WordWrap
        text: {
            if (root.defaultMessageCondition) {
                return root.defaultMessage
            }
            if (!root.addressDetailsItem || !root.addressDetailsItem.loaded) {
                return qsTr("Scanning for activity...")
            }
            if (root.alreadyCreatedAccountIsAnError && root.addressDetailsItem.alreadyCreated) {
                return qsTr("Already added")
            }
            if (root.addressDetailsItem.hasActivity) {
                return qsTr("Has activity")
            }
            return qsTr("No activity")
        }
        color: {
            if (root.defaultMessageCondition || !root.addressDetailsItem || !root.addressDetailsItem.loaded) {
                return Theme.palette.baseColor1
            }
            if (root.alreadyCreatedAccountIsAnError && root.addressDetailsItem.alreadyCreated) {
                return Theme.palette.dangerColor1
            }
            if (root.addressDetailsItem.hasActivity) {
                return Theme.palette.successColor1
            }
            return Theme.palette.warningColor1
        }
    }
}
