import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import QtWebChannel 1.13
import "../../../imports"
import "../../../shared"

WebEngineView {
    id: testWebEngineView
    focus: true
    // url: "https://dap.ps/"
    url: "./test.html"

    webChannel: pluginChannel
    // property QtObject otrProfile: WebEngineProfile {
    profile: WebEngineProfile {
        offTheRecord: true
        persistentCookiesPolicy:  WebEngineProfile.NoPersistentCookies
        // httpUserAgent: defaultProfile.httpUserAgent
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("plugin.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop 
            }
        ]
    }

    Connections {
        target: chatsModel

        onMessageNotificationPushed: function(chatId, msg, messageType, chatType, timestamp, identicon, username, hasMention, isAddedContact, channelName) {
            console.log("message received")
            console.log(msg)
        }

        onFullMessagePushed: function (chatId, message) {
            console.log(message.length)
            pluginProvider.pluginResponse(message)
        }
    }

    QtObject {
        id: pluginProvider
        WebChannel.id: "plugin"

        signal pluginResponse(string data);

        function postMessage(data) {
            chatsModel.sendMessage(data, "", Constants.messageType, false);
            // console.log("hi there")
            // pluginResponse("hi")
        }
    }

    WebChannel {
        id: pluginChannel
        registeredObjects: [pluginProvider]
    }

}

// Item {
//     id: nodeView
//     Layout.fillHeight: true
//     Layout.fillWidth: true

//     ColumnLayout {
//         id: rpcColumn
//         spacing: 0
//         anchors.fill: parent

//         ColumnLayout {
//             id: messageContainer
//             Layout.fillHeight: true
//             StyledText {
//                 id: testDescription
//                 color: Style.current.lightBlueText
//                 text: "latest block (auto updates):"
//                 Layout.rightMargin: Style.current.padding
//                 Layout.leftMargin: Style.current.padding
//                 Layout.fillWidth: true
//                 font.weight: Font.Medium
//                 font.pixelSize: 20
//             }
//             StyledText {
//                 id: test
//                 color: Style.current.lightBlueText
//                 text: nodeModel.lastMessage
//                 Layout.rightMargin: Style.current.padding
//                 Layout.leftMargin: Style.current.padding
//                 Layout.fillWidth: true
//                 font.weight: Font.Medium
//                 font.pixelSize: 20
//             }
//         }

//         RowLayout {
//             id: resultContainer
//             Layout.fillHeight: true
//             Layout.rightMargin: Style.current.padding
//             Layout.leftMargin: Style.current.padding
//             TextArea { id: callResult; Layout.fillWidth: true; text: nodeModel.callResult; readOnly: true }
//         }

//         RowLayout {
//             id: rpcInputContainer
//             height: 70
//             Layout.fillWidth: true
//             Layout.bottomMargin: 0
//             Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
//             transformOrigin: Item.Bottom

//             Item {
//                 id: element2
//                 width: 200
//                 height: 70
//                 Layout.fillWidth: true

//                 Rectangle {
//                     id: rectangle
//                     color: "#00000000"
//                     border.color: Style.current.border
//                     anchors.fill: parent

//                     Button {
//                         id: rpcSendBtn
//                         x: 100
//                         width: 30
//                         height: 30
//                         text: "\u2191"
//                         font.bold: true
//                         font.pointSize: 12
//                         anchors.top: parent.top
//                         anchors.topMargin: 20
//                         anchors.right: parent.right
//                         anchors.rightMargin: 16
//                         onClicked: {
//                             nodeModel.onSend(txtData.text)
//                             txtData.text = ""
//                         }
//                         enabled: txtData.text !== ""
//                         background: Rectangle {
//                             color: parent.enabled ? Style.current.blue : Style.current.grey
//                             radius: 50
//                         }
//                     }

//                     StyledTextField {
//                         id: txtData
//                         text: ""
//                         leftPadding: 0
//                         padding: 0
//                         font.pixelSize: 14
//                         //% "Type json-rpc message... e.g {\"method\": \"eth_accounts\"}"
//                         placeholderText: qsTrId("type-json-rpc-message")
//                         anchors.right: rpcSendBtn.left
//                         anchors.rightMargin: 16
//                         anchors.top: parent.top
//                         anchors.topMargin: 24
//                         anchors.left: parent.left
//                         anchors.leftMargin: 24
//                         Keys.onEnterPressed: {
//                             nodeModel.onSend(txtData.text)
//                             txtData.text = ""
//                         }
//                         Keys.onReturnPressed: {
//                             nodeModel.onSend(txtData.text)
//                             txtData.text = ""
//                         }
//                         background: Rectangle {
//                             color: "#00000000"
//                         }
//                     }

//                     MouseArea {
//                         id: mouseArea1
//                         anchors.rightMargin: 50
//                         anchors.fill: parent
//                         onClicked : {
//                             txtData.forceActiveFocus(Qt.MouseFocusReason)
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5;height:770;width:1152}
}
##^##*/
