import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1

import utils 1.0
import shared 1.0

Item {
    property alias text: loadingText.text
    ColumnLayout {
        anchors.centerIn: parent
        LoadingAnimation {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 128
            Layout.preferredHeight: 128
            source: Style.png("status-logo")
        }
        StatusBaseText {
            id: loadingText
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("Loading Status...")
        }
    }
}
