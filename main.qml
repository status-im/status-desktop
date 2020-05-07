import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    width: 1024
    height: 768
    title: "JSON RPC Caller"
    visible: true

    SplitView {
        anchors.fill: parent

        Item {
            width: 300
            height: parent.height
        }

        Item {
            width: parent.width/2
            height: parent.height

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    TextArea { id: callResult; Layout.fillWidth: true; text: logic.callResult; readOnly: true }
                }

                RowLayout {
                    Label { text: "data2" }
                    TextField { id: txtData; Layout.fillWidth: true; text: "" }
                    Button {
                        text: "Send"
                        onClicked: logic.onSend(txtData.text)
                        enabled: txtData.text !== ""
                    }
                }
            }

        }

    }

}
