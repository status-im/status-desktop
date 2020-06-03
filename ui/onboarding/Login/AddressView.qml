import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

Item {
    property string username: "Jotaro Kujo"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

    id: addressViewDelegate
    height: 56
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0

    Row {
        RadioButton {
            checked: index == 0 ? true : false
            ButtonGroup.group: accountGroup
            onClicked: {
                wizardStep1.selectedIndex = index
            }
        }
        Column {
            Image {
                source: identicon
            }
        }
        Column {
            Text {
                text: username
            }
        }
    }
}
