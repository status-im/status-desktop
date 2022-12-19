import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../panels"

Column {
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
        anchors.horizontalCenter: parent.horizontalCenter
        height: 20
        width: 20
        icon: "cancel"
        color: Theme.palette.dangerColor1
        visible: !d.isValid && !isLoading
    }
    StatusLoadingIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 24
        height: 24
        color: Theme.palette.baseColor1
        visible: isLoading && d.isValid
    }
    StyledText {
        id: txtValidationError
        anchors.horizontalCenter: parent.horizontalCenter
        text: isLoading ? qsTr("Calculating fees"): errorType === Constants.SendAmountExceedsBalance ?
                              qsTr("Balance exceeded") : qsTr("No route found")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
