import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

import "stores"
import "views"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    property RootStore store: RootStore {}

    ColumnLayout {
        id: rpcColumn
        spacing: 0
        anchors.fill: parent

        RateView {
            store: root.store
        }

        RowLayout {
            id: peerContainer2
            Layout.fillWidth: true
            StatusBaseText {
                id: peerDescription
                color: Theme.palette.primaryColor1
                text: "Peers"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StatusBaseText {
                id: peerNumber
                color: Theme.palette.primaryColor1
                // Not Refactored Yet
                text: root.store.nodeModelInst.peerSize
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
            StatusBaseText {
                color: Theme.palette.primaryColor1
                text: qsTr("Bloom Filter Usage")
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StatusBaseText {
                id: bloomPerc
                color: Theme.palette.primaryColor1
                text: ((root.store.nodeModelInst.bloomBits / 512) * 100).toFixed(2) + "%"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
        }

        ColumnLayout {
            id: mailserverLogsContainer
            height: 300
            StatusBaseText {
                color: Theme.palette.primaryColor1
                text: "Mailserver Interactions:"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            // TODO: replace with StatusTextArea once it lives in StatusQ.
            StyledTextArea {
                id: mailserverLogTxt
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                text: ""
                customHeight: 200
                textField.readOnly: true
            }
        }

        ColumnLayout {
            id: logContainer
            height: 300
            StatusBaseText {
                id: logHeaderDesc
                color: Theme.palette.primaryColor1
                text: "Logs:"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            // TODO: replace with StatusTextArea once it lives in StatusQ.
            StyledTextArea {
                id: logsTxt
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                text: ""
                customHeight: 200
                textField.readOnly: true
            }
        }

        // Not Refactored Yet
        Connections {
            target: root.store.nodeModelInst
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
            StatusBaseText {
                id: testDescription
                color: Theme.palette.primaryColor1
                text: "latest block (auto updates):"
                Layout.rightMargin: Style.current.padding
                Layout.leftMargin: Style.current.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: 20
            }
            StatusBaseText {
                id: test
                color: Theme.palette.primaryColor1
                // Not Refactored Yet
                text: root.store.nodeModelInst.lastMessage
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
            // TODO: replace with StatusTextArea once it lives in StatusQ.
            // Not Refactored Yet
            TextArea { id: callResult; Layout.fillWidth: true; text: root.store.nodeModelInst.callResult; readOnly: true }
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
                            root.store.onSend(txtData.text)
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
                        placeholderText: qsTr("Type json-rpc message... e.g {\"method\": \"eth_accounts\"}")
                        anchors.right: rpcSendBtn.left
                        anchors.rightMargin: 16
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        Keys.onEnterPressed: {
                            root.store.onSend(txtData.text)
                            txtData.text = ""
                        }
                        Keys.onReturnPressed: {
                            root.store.onSend(txtData.text)
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
