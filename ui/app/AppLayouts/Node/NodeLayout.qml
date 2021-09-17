import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"


Item {
    id: nodeView
    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout {
        id: rpcColumn
        spacing: 0
        anchors.fill: parent

        Rate {

        }

        RowLayout {
            id: peerContainer2
            Layout.fillWidth: true
            StyledText {
                id: peerDescription
                color: Style.current.lightBlueText
                text: "Peers"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StyledText {
                id: peerNumber
                color: Style.current.lightBlueText
                text: nodeModel.peerSize
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
        }

        RowLayout {
            id: bloomF
            Layout.fillWidth: true
            StyledText {
                color: Style.current.lightBlueText
                text: qsTr("Bloom Filter Usage")
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StyledText {
                id: bloomPerc
                color: Style.current.lightBlueText
                text: ((nodeModel.bloomBits / 512) * 100).toFixed(2) + "%"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
        }

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                color: Style.current.lightBlueText
                text: qsTr("Active Mailserver")
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StyledText {
                id: activeMailserverTxt
                color: Style.current.textColor
                text: "..."
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.weight: Font.Medium
                font.pixelSize: 14
            }
        }

        Connections {
            target: profileModel.mailservers
            onActiveMailserverChanged: (activeMailserver) => {
                activeMailserverTxt.text = profileModel.mailservers.list.getMailserverName(activeMailserver) + "\n" + activeMailserver
            }
        }

        ColumnLayout {
            id: mailserverLogsContainer
            height: 300
            StyledText {
                color: Style.current.lightBlueText
                text: "Mailserver Interactions:"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StyledTextArea {
                id: mailserverLogTxt
                text: ""
                customHeight: 200
                textField.readOnly: true
            }
        }

        ColumnLayout {
            id: logContainer
            height: 300
            StyledText {
                id: logHeaderDesc
                color: Style.current.lightBlueText
                text: "Logs:"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StyledTextArea {
                id: logsTxt
                text: ""
                customHeight: 200
                textField.readOnly: true
            }
        }

        Connections {
            target: nodeModel
            function onLog(logContent) {
                // TODO: this is ugly, but there's not even a design for this section
                if(logContent.indexOf("mailserver") > 0){
                    let lines = mailserverLogTxt.text.split("\n");
                    if (lines.length > 10){
                        lines.shift();
                    }
                    lines.push(logContent.trim())
                    mailserverLogTxt.text = lines.join("\n")
                } else {
                    let lines = logsTxt.text.split("\n");
                    if (lines.length > 5){
                        lines.shift();
                    }
                    lines.push(logContent.trim())
                    logsTxt.text = lines.join("\n")
                }
            }
        }

        ColumnLayout {
            id: messageContainer
            Layout.fillHeight: true
            StyledText {
                id: testDescription
                color: Style.current.lightBlueText
                text: "latest block (auto updates):"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StyledText {
                id: test
                color: Style.current.lightBlueText
                text: nodeModel.lastMessage
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
        }

        RowLayout {
            id: resultContainer
            Layout.fillHeight: true
            Layout.rightMargin: Style.current.padding
            Layout.leftMargin: Style.current.padding
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
                    border.color: Style.current.border
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
                            color: parent.enabled ? Style.current.blue : Style.current.grey
                            radius: 50
                        }
                    }

                    StyledTextField {
                        id: txtData
                        text: ""
                        leftPadding: 0
                        padding: 0
                        font.pixelSize: 14
                        //% "Type json-rpc message... e.g {\"method\": \"eth_accounts\"}"
                        placeholderText: qsTrId("type-json-rpc-message")
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
