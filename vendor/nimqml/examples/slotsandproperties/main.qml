import QtQuick 2.8
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    width: 400
    height: 300

    Component.onCompleted: visible = true

    ColumnLayout {
        anchors.fill: parent

        Label { text: "Current name is:" + contact.name }

        TextField { id: textField }

        Button {
            text: "Change Name"
            onClicked: contact.name = textField.text
        }
    }
}
