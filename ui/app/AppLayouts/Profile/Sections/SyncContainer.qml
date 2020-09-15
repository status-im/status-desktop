import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: syncContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element4
        //% "Sync settings"
        text: qsTrId("sync-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Component {
        id: mailserversList
        
        RadioButton {
            id: control
            indicator: Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                x: control.leftPadding
                y: parent.height / 2 - height / 2
                radius: 13
                border.color: control.down ? "#17a81a" : "#21be2b"

                Rectangle {
                    width: 14
                    height: 14
                    x: 6
                    y: 6
                    radius: 7
                    color: control.down ? "#17a81a" : "#21be2b"
                    visible: control.checked
                }
            }
            contentItem: StyledText {
                text: name
                color: Style.current.textColor
                leftPadding: control.indicator.width + control.spacing
            }
            checked: index == 0 ? true: false
        }
    }

    ListView {
        id: mailServersListView
        anchors.topMargin: 48
        anchors.top: element4.bottom
        anchors.fill: parent
        model: profileModel.mailserversList
        delegate: mailserversList
    }
}
