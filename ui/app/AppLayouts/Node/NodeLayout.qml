import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Layout
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils
import shared
import shared.panels
import shared.controls

import "stores"
import "views"

StatusSectionLayout {
    id: root

    property RootStore store: RootStore {}

    centerPanel: ColumnLayout {
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
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSize(20)
            }
            StatusBaseText {
                id: peerNumber
                color: Theme.palette.primaryColor1
                // Not Refactored Yet
                text: root.store.nodeModelInst.peerSize
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSize(20)
            }
        }

        ColumnLayout {
            id: mailserverLogsContainer
            height: 300
            StatusBaseText {
                color: Theme.palette.primaryColor1
                text: "Mailserver Interactions:"
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSize(20)
            }
            StatusTextArea {
                id: mailserverLogTxt
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                text: ""
                readOnly: true
            }
        }

        ColumnLayout {
            id: logContainer
            height: 300
            StatusBaseText {
                id: logHeaderDesc
                color: Theme.palette.primaryColor1
                text: "Logs:"
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSize(20)
            }
            StatusTextArea {
                id: logsTxt
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                text: ""
                readOnly: true
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
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSize(20)
            }
            StatusBaseText {
                id: test
                color: Theme.palette.primaryColor1
                // Not Refactored Yet
                text: root.store.nodeModelInst.lastMessage
                Layout.rightMargin: Theme.padding
                Layout.leftMargin: Theme.padding
                Layout.fillWidth: true
                font.weight: Font.Medium
                font.pixelSize: Theme.fontSize(20)
            }
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
                    border.color: Theme.palette.border
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
                            color: parent.enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                            radius: 50
                        }
                    }

                    StatusTextField {
                        id: txtData
                        text: ""
                        leftPadding: 0
                        padding: 0
                        font.pixelSize: Theme.secondaryTextFontSize
                        placeholderText: qsTr("Type json-rpc message... e.g {\"method\": \"eth_accounts\"}")
                        anchors.right: rpcSendBtn.left
                        anchors.rightMargin: 16
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        onAccepted: {
                            root.store.onSend(txtData.text)
                            txtData.text = ""
                        }
                        background: Rectangle {
                            color: "#00000000"
                        }
                    }
                }
            }
        }

        RowLayout {
            id: resultContainer
            Layout.fillHeight: true
            Layout.rightMargin: Theme.padding
            Layout.leftMargin: Theme.padding
            StatusTextArea { 
                id: callResult
                Layout.fillWidth: true
                text: root.store.nodeModelInst.callResult
                readOnly: true
            }
        }
    }
}
