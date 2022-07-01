import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: balancedExceededError

    property bool transferPossible: false
    property double amountToSend: 0

    StatusIcon {
        Layout.alignment: Qt.AlignHCenter
        visible: !balancedExceededError.transferPossible && balancedExceededError.amountToSend > 0
        icon: "cancel"
        color: Theme.palette.dangerColor1
    }
    StatusBaseText {
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 15
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.dangerColor1
        text: balancedExceededError.amountToSend > 0 ? qsTr("Balance exceeded"): qsTr("No networks available")
        wrapMode: Text.WordWrap
    }
}
