import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    width: 800
    height: 300
    title: "JSON RPC Caller"
    visible: true

    menuBar: MenuBar {
        Menu {
            title: "&File"
            MenuItem { text: "&Exit"; onTriggered: logic.onExitTriggered() }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            TextArea { id: callResult; Layout.fillWidth: true; text: logic.callResult; readOnly: true }
        }

        RowLayout {
            Label { text: "data" }
            TextField { id: txtData; Layout.fillWidth: true; text: "" }
            Button {
                text: "Send"
                onClicked: logic.onSend(txtData.text)
                enabled: txtData.text !== ""
            }
        }
    }
}
