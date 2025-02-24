import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0

Item {
    id: root

    property alias text: loadingText.text
    property alias secondaryText: secondaryText.text
    property alias progress: progressBar.value
    property bool infiniteLoading: false

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        Image {
            objectName: "loadingAnimation"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 320
            Layout.preferredHeight: 320
            source: Theme.png("status-preparing")
        }
        StatusBaseText {
            id: loadingText
            Layout.topMargin: 12
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.pixelSize: 22
            font.bold: true
            text: qsTr("Preparing Status for you")
        }
        StatusBaseText {
            id: secondaryText
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            color: Theme.palette.baseColor1
            text: qsTr("Hang in there! Just a few more seconds!")
        }
        StatusProgressBar {
            id: progressBar
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            Layout.preferredHeight: 4
            Layout.bottomMargin: 100
            fillColor: Theme.palette.primaryColor1
            visible: !root.infiniteLoading
        }
        LoadingAnimation {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.preferredHeight: 25
            Layout.preferredWidth: 25
            Layout.bottomMargin: 100
            visible: root.infiniteLoading
        }
    }
}
