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

    property bool isLoading: false
    property int errorType: Constants.NoError

    visible: balancedExceededError.errorType !== Constants.NoError || isLoading

    StatusIcon {
        Layout.preferredHeight: 20
        Layout.preferredWidth: 20
        Layout.alignment: Qt.AlignHCenter
        icon: "cancel"
        color: Theme.palette.dangerColor1
        visible: !isLoading
    }
    StatusBaseText {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.dangerColor1
        text: balancedExceededError.errorType === Constants.SendAmountExceedsBalance ? qsTr("Balance exceeded") :
              balancedExceededError.errorType === Constants.NoRoute ? qsTr("No route found") : ""
        wrapMode: Text.WordWrap
        visible: !isLoading
    }
    Loader {
        Layout.alignment: Qt.AlignLeft
        Layout.preferredHeight: 32
        Layout.fillWidth: true
        active: isLoading
        sourceComponent: LoadingComponent { radius: 4 }
    }
}
