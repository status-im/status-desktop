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

    visible: !isValid || isLoading
    spacing: 5

    property alias errorMessage: txtValidationError.text
    property bool isValid: true
    property bool isLoading: false

    StatusIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        height: 20
        width: 20
        icon: "cancel"
        color: Theme.palette.dangerColor1
        visible: !isValid && !isLoading
    }
    StatusLoadingIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 24
        height: 24
        color: Theme.palette.baseColor1
        visible: isLoading && isValid
    }
    StyledText {
        id: txtValidationError
        anchors.horizontalCenter: parent.horizontalCenter
        text: isLoading? qsTr("Calculating fees"): qsTr("Balance exceeded")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
