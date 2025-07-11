import QtQuick 2.13
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ.Controls
import StatusQ.Popups
import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme

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
        font.pixelSize: Theme.additionalTextSize
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
