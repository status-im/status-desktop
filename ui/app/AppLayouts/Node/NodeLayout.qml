import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"

SplitView {
    id: nodeView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout {
        id: rpcColumn
        spacing: 0
//        anchors.left: contactsColumn.right
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        ColumnLayout {
            id: messageContainer
            Layout.fillHeight: true
            Text {
                id: testDescription
                color: Theme.lightBlueText
                text: "latest block (auto updates):"
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            Text {
                id: test
                color: Theme.lightBlueText
                text: nodeModel.lastMessage
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
        }

        RowLayout {
            id: resultContainer
            Layout.fillHeight: true
            Layout.rightMargin: Theme.padding
            Layout.leftMargin: Theme.padding
            TextArea { id: callResult; Layout.fillWidth: true; text: nodeModel.callResult; readOnly: true }
        }

        RowLayout {
            id: rpcInputContainer
            height: 70
            Layout.fillWidth: true
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            transformOrigin: Item.Bottom

            Item {
                id: element2
                width: 200
                height: 70
                Layout.fillWidth: true

                Rectangle {
                    id: rectangle
                    color: "#00000000"
                    border.color: Theme.grey
                    anchors.fill: parent

                    Button {
                        id: rpcSendBtn
                        x: 100
                        width: 30
                        height: 30
                        text: "\u2191"
                        font.bold: true
                        font.pointSize: 12
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        onClicked: {
                            nodeModel.onSend(txtData.text)
                            txtData.text = ""
                        }
                        enabled: txtData.text !== ""
                        background: Rectangle {
                            color: parent.enabled ? Theme.blue : Theme.grey
                            radius: 50
                        }
                    }

                    TextField {
                        id: txtData
                        text: ""
                        leftPadding: 0
                        padding: 0
                        font.pixelSize: 14
                        placeholderText: qsTr("Type json-rpc message... e.g {\"method\": \"eth_accounts\"}")
                        anchors.right: rpcSendBtn.left
                        anchors.rightMargin: 16
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        Keys.onEnterPressed: {
                            nodeModel.onSend(txtData.text)
                            txtData.text = ""
                        }
                        Keys.onReturnPressed: {
                            nodeModel.onSend(txtData.text)
                            txtData.text = ""
                        }
                        background: Rectangle {
                            color: "#00000000"
                        }
                    }

                    MouseArea {
                        id: mouseArea1
                        anchors.rightMargin: 50
                        anchors.fill: parent
                        onClicked : {
                            txtData.forceActiveFocus(Qt.MouseFocusReason)
                        }
                    }
                }
            }
        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorZoom:0.5;height:770;width:1152}
}
##^##*/
