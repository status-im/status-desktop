import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

import utils

Row {
    id: root

    property var addressDetailsItem
    property bool defaultMessageCondition: true
    property string defaultMessage: ""
    property bool alreadyCreatedAccountIsAnError: true

    StatusIcon {
        id: icon
        visible: root.addressDetailsItem &&
                 root.addressDetailsItem.detailsLoaded &&
                 root.addressDetailsItem.address !== "" &&
                 root.addressDetailsItem.hasActivity
        width: 20
        height: 20
        icon: "flash"
        color: Theme.palette.successColor1
    }

    StatusBaseText {
        width: icon.visible? parent.width - icon.width : parent.width
        font.pixelSize: Theme.additionalTextSize
        wrapMode: Text.WordWrap
        text: {
            if (root.defaultMessageCondition) {
                return root.defaultMessage
            }
            if (root.alreadyCreatedAccountIsAnError &&
                    root.addressDetailsItem.alreadyCreated) {
                return qsTr("Already added")
            }
            if(root.addressDetailsItem.detailsLoaded &&
                    root.addressDetailsItem.errorInScanningActivity) {
                return qsTr("Activity unknown")
            }
            if (!root.addressDetailsItem || !root.addressDetailsItem.detailsLoaded) {
                return qsTr("Scanning for activity...")
            }
            if (root.addressDetailsItem.hasActivity) {
                return qsTr("Has activity")
            }
            return qsTr("No activity")
        }
        color: {
            if (root.alreadyCreatedAccountIsAnError &&
                    root.addressDetailsItem.alreadyCreated) {
                return Theme.palette.dangerColor1
            }
            if (root.defaultMessageCondition || !root.addressDetailsItem || !root.addressDetailsItem.detailsLoaded) {
                return Theme.palette.baseColor1
            }
            if (root.addressDetailsItem.hasActivity) {
                return Theme.palette.successColor1
            }
            return Theme.palette.warningColor1
        }
    }
}
