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
    property bool isLoading: true

    visible: !balancedExceededError.transferPossible || isLoading

    StatusIcon {
        Layout.preferredHeight: 20
        Layout.preferredWidth: 20
        Layout.alignment: Qt.AlignHCenter
        icon: "cancel"
        color: Theme.palette.dangerColor1
        visible: !isLoading
    }
    StatusLoadingIndicator {
        Layout.preferredHeight: 24
        Layout.preferredWidth: 24
        Layout.alignment: Qt.AlignHCenter
        color: Theme.palette.baseColor1
        visible: isLoading
    }
    StatusBaseText {
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.dangerColor1
        text: isLoading ? qsTr("Calculating fees") : qsTr("Balance exceeded")
        wrapMode: Text.WordWrap
    }
}
