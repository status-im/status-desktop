import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Column {
    id: root
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 5

    visible: !isValid || isWarn

    property bool isValid: true
    property bool isWarn: address == Constants.zeroAddress
    property alias errorMessage: txtValidationError.text
    property string address: ""

    StatusIcon {
        width: 13.33
        height: 13.33
        anchors.horizontalCenter: parent.horizontalCenter
        icon: "warning"
        color: Theme.palette.dangerColor1
    }

    StatusBaseText {
        id: txtValidationError
        text: qsTr("You need to request the recipient’s address first.\nAssets won’t be sent yet.")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 13
        height: 18
        color: Theme.palette.dangerColor1
    }
}
