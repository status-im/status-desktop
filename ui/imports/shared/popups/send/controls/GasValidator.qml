import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils

import shared.panels

ColumnLayout {
    id: root

    property int errorType: Constants.NoError
    property bool isLoading: false

    QtObject {
        id: d
        readonly property bool isValid: root.errorType === Constants.NoError
    }

    visible: !d.isValid || isLoading
    spacing: 5

    StatusIcon {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 20
        Layout.preferredWidth: 20
        icon: "cancel"
        color: Theme.palette.dangerColor1
        visible: !d.isValid && !isLoading
    }
    StyledText {
        id: txtValidationError
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 18
        text: errorType === Constants.SendAmountExceedsBalance ?
                  qsTr("Balance exceeded") : qsTr("No route found")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.additionalTextSize
        color: Theme.palette.dangerColor1
        visible: !isLoading
    }
    Loader {
        id: loadingComponent
        Layout.preferredHeight: 32
        Layout.preferredWidth: root.width - Theme.xlPadding
        active: isLoading && d.isValid
        sourceComponent: LoadingComponent { radius: 4 }
    }
}
