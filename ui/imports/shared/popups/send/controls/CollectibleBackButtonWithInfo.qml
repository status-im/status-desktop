import QtQuick 2.15
import QtQuick.Layouts 1.13

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Rectangle {

    property int count
    property string name
    signal backClicked()

    QtObject {
        id:d
        readonly property int padding: 16
        readonly property int backButtonWidth: 56
        readonly property int backButtonHeight: 24
    }

    implicitHeight: 40
    color: "transparent"
    border.color: Theme.palette.baseColor2
    border.width: 1

    RowLayout{
        anchors.fill: parent

        StatusIconTextButton {
            Layout.preferredWidth: d.backButtonWidth
            Layout.preferredHeight: d.backButtonHeight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: d.padding

            statusIcon: "previous"
            icon.width: 16
            icon.height: 16
            text: qsTr("Back")

            onClicked: backClicked()
        }
        StatusBaseText {
            Layout.fillWidth: true
            Layout.rightMargin: d.padding
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: "%1 %2".arg(count).arg(name)
            font.pixelSize: 13
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.baseColor1
        }
    }
}
