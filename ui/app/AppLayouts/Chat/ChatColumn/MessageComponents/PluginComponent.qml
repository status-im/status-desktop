import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.0
import QtWebEngine 1.10
import QtWebChannel 1.13
import "../../../../../shared"
import "../../../../../imports"

WebEngineView {
    property var clickMessage: function () {}
    property string linkUrls: ""
    property bool isCurrentUser: false
    property int contentType: 2
    property var container

    Component.onCompleted: function() {
        console.log("rendering done!") 
        console.log(plainText.split("|")[1]) 
        let pluginInit = JSON.parse(plainText.split("|")[1])
        console.log("name:" + pluginInit.name)
        console.log("id:" + pluginInit.id)
        pluginProvider.pluginResponse('messages', "blue,red")
        // pluginProvider.pluginResponse('messages', "blue,red")
        // setTimeout(() => {
        // }, 500)
    //     testWebEngineView.loadHtml('<html>    <head>    </head>    <body>        <button class="mybutton" onClick="javascript:hello()">hello</button>        <button class="mybutton" onClick="javascript:toColor(\'red\')">change to red</button>        <button class="mybutton" onClick="javascript:toColor(\'blue\')">change to blue</button>    </body></html>')
   }

    onLoadingChanged: function(loadRequest) {
        if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
            pluginProvider.pluginResponse('messages', "blue,red")
        }
    }

    anchors.top: parent.top
    anchors.topMargin: Style.current.smallPadding
    // height: childrenRect.height + this.anchors.topMargin + (dateGroupLbl.visible ? dateGroupLbl.height : 0)
    height: 4 * (childrenRect.height + this.anchors.topMargin)
    width: parent.width

    id: testWebEngineView
    focus: true
    // url: "https://dap.ps/"
    url: "./test.html"
    // url: "./test2.html"

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

        onPluginMessagePushed: function(chatId, msg, messageType, chatType, timestamp, identicon, username, hasMention, isAddedContact, channelName) {
            console.log("= message received")
            console.log(msg)
            // console.log(fromAuthor)
            // console.log(alias)
            // console.log(localName)
            // console.log(identicon)
            // console.log(timestamp)
            if (msg.indexOf("pluginMsg|") !== 0) {
                return
            }
            let pluginInit = JSON.parse(plainText.split("|")[1])
            let msgPackage = JSON.parse(msg.split("|")[1])
            if (pluginInit.id === msgPackage.id) {
                console.log("matching message")
                let pkg = JSON.stringify({ data: msgPackage.msg, identicon, username, timestamp })
                console.log(pkg)
                pluginProvider.pluginResponse('message', pkg)
            }
        }

        onFullMessagePushed: function (chatId, message) {
            // console.log(message.length)
            // pluginProvider.pluginResponse('message', message)
        }
    }

    QtObject {
        id: pluginProvider
        WebChannel.id: "plugin"

        signal pluginResponse(string messageType, string data);

        function postMessage(data) {
            // pluginFileDialog.open()
            let pluginInit = JSON.parse(plainText.split("|")[1])
            chatsModel.sendPluginMessage(JSON.stringify({id: pluginInit.id, msg: data})); // console.log("hi there")
            // pluginResponse("hi")
        }
    }

    WebChannel {
        id: pluginChannel
        registeredObjects: [pluginProvider]
    }

    FileDialog {
        id: pluginFileDialog
        //% "Please choose an image"
        title: qsTrId("please-choose-an-plugin")
        folder: shortcuts.pictures
        nameFilters: [
            //% "Image files (*.jpg *.jpeg *.png)"
            qsTrId("image-files----jpg---jpeg---png-")
        ]
        onAccepted: {
            console.log("You chose: " + pluginFileDialog.fileUrls)
        }
        // onAccepted: {
        //     imageBtn.highlighted = false
        //     imageBtn2.highlighted = false
        //     control.showImageArea()
        //     messageInputField.forceActiveFocus();
        // }
        // onRejected: {
        //     imageBtn.highlighted = false
        //     imageBtn2.highlighted = false
        // }
    }

}



// Item {
//     property var clickMessage: function () {}
//     property string linkUrls: ""
//     property bool isCurrentUser: false
//     property int contentType: 2
//     property var container

//     id: root
//     anchors.top: parent.top
//     anchors.topMargin: authorCurrentMsg !== authorPrevMsg ? Style.current.smallPadding : 0
//     height: childrenRect.height + this.anchors.topMargin + (dateGroupLbl.visible ? dateGroupLbl.height : 0)
//     width: parent.width

//     DateGroup {
//         id: dateGroupLbl
//     }

//     UserImage {
//         id: chatImage
//         visible: chatsModel.activeChannel.chatType !== Constants.chatTypeOneToOne && isMessage && authorCurrentMsg != authorPrevMsg && !root.isCurrentUser
//         anchors.left: parent.left
//         anchors.leftMargin: Style.current.padding
//         anchors.top:  dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
//         anchors.topMargin: 20
//     }

//     UsernameLabel {
//         id: chatName
//         visible: chatsModel.activeChannel.chatType !== Constants.chatTypeOneToOne && isMessage && authorCurrentMsg != authorPrevMsg && !root.isCurrentUser
//         anchors.leftMargin: 20
//         anchors.top: dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top
//         anchors.topMargin: 0
//         anchors.left: chatImage.right
//     }

//     Rectangle {
//         readonly property int defaultMessageWidth: 400
//         readonly property int defaultMaxMessageChars: 54
//         readonly property int messageWidth: Math.max(defaultMessageWidth, parent.width / 1.4)
//         readonly property int maxMessageChars: (defaultMaxMessageChars * messageWidth) / defaultMessageWidth
//         property int chatVerticalPadding: isImage ? 4 : 6
//         property int chatHorizontalPadding: isImage ? 0 : 12
//         property bool longReply: chatReply.visible && repliedMessageContent.length > maxMessageChars
//         property bool longChatText: chatsModel.plainText(message).split('\n').some(function (messagePart) {
//             return messagePart.length > maxMessageChars
//         })

//         id: chatBox
//         color: {
//             if (isSticker) {
//                 return Style.current.background 
//             }
//             if (isImage) {
//                 return "transparent"
//             }
//             return root.isCurrentUser ? Style.current.primary : Style.current.secondaryBackground
//         }
//         border.color: isSticker ? Style.current.border : Style.current.transparent
//         border.width: 1
//         height: {
//            let h = (3 * chatVerticalPadding)
//            switch(contentType){
//                 case Constants.stickerType:
//                     h += stickerId.height;
//                     break;
//                 case Constants.audioType:
//                     h += audioPlayerLoader.height;
//                     break;
//                 default:
//                     if (!chatImageContent.active && !chatReply.active) {
//                         h -= chatVerticalPadding
//                     }

//                     h += chatText.visible ? chatText.height : 0;
//                     h += chatImageContent.active ? chatImageContent.height: 0;
//                     h += chatReply.active ? chatReply.height : 0;
//            }
//            return h;
//         }
//         width: {
//             switch(contentType) {
//                 case Constants.stickerType:
//                     return stickerId.width + (2 * chatBox.chatHorizontalPadding);
//                 case Constants.imageType:
//                     return chatImageContent.width
//                 default:
//                     if (longChatText || longReply) {
//                         return messageWidth;
//                     }
//                     let baseWidth = chatText.width;
//                     if (chatReply.visible && chatText.width < chatReply.textFieldWidth) {
//                         baseWidth = chatReply.textFieldWidth
//                     }

//                     if (chatReply.visible && chatText.width < chatReply.authorWidth) {
//                         if(chatReply.authorWidth > baseWidth){
//                             baseWidth = chatReply.authorWidth + 20
//                         }
//                     }

//                     return baseWidth + 2 * chatHorizontalPadding
//             }
//         }

//         radius: 16
//         anchors.left: !root.isCurrentUser ? chatImage.right : undefined
//         anchors.leftMargin: !root.isCurrentUser ? 8 : 0
//         anchors.right: !root.isCurrentUser ? undefined : parent.right
//         anchors.rightMargin: !root.isCurrentUser ? 0 : Style.current.padding
//         anchors.top: authorCurrentMsg != authorPrevMsg && !root.isCurrentUser ? chatImage.top : (dateGroupLbl.visible ? dateGroupLbl.bottom : parent.top)
//         anchors.topMargin: 0
//         visible: isMessage

//         ChatReply {
//             id: chatReply
//             longReply: chatBox.longReply
//             anchors.top: parent.top
//             anchors.topMargin: chatReply.visible ? chatBox.chatVerticalPadding : 0
//             anchors.left: parent.left
//             anchors.leftMargin: Style.current.padding
//             anchors.right: parent.right
//             anchors.rightMargin: chatBox.chatHorizontalPadding
//             container: root.container
// 	    chatHorizontalPadding: chatBox.chatHorizontalPadding
//         }

//         ChatText {
//             id: chatText
//             longChatText: "plugin: " + chatBox.longChatText
//             anchors.top: chatReply.bottom
//             anchors.topMargin: chatReply.active ? chatBox.chatVerticalPadding : 0
//             anchors.left: parent.left
//             anchors.leftMargin: chatBox.chatHorizontalPadding
//             anchors.right: chatBox.longChatText ? parent.right : undefined
//             anchors.rightMargin: chatBox.longChatText ? chatBox.chatHorizontalPadding : 0
//             textField.color: !root.isCurrentUser ? Style.current.textColor : Style.current.currentUserTextColor
//             Connections {
//                 target: appSettings.compactMode ? null : chatBox
//                 onLongChatTextChanged: {
//                     chatText.setWidths()
//                 }
//             }
//         }

//         Loader {
//             id: chatImageContent
//             active: isImage && !!image
//             anchors.top: parent.top
//             anchors.topMargin: Style.current.smallPadding
//             anchors.left: parent.left
//             anchors.leftMargin: chatBox.chatHorizontalPadding
//             z: 51

//             sourceComponent: Component {
//                 Item {
//                     width: chatImageComponent.width + 2 * chatBox.chatHorizontalPadding
//                     height: chatImageComponent.height

//                     ChatImage {
//                         id: chatImageComponent
//                         imageSource: image
//                         imageWidth: 250
//                         isCurrentUser: root.isCurrentUser
//                         onClicked: root.clickMessage(false, false, true, image)
//                         container: root.container
//                     }
//                 }
//             }
//         }

//         Loader {
//             id: audioPlayerLoader
//             active: isAudio
//             sourceComponent: audioPlayer
//             anchors.verticalCenter: parent.verticalCenter
//         }

//         Component {
//             id: audioPlayer
//             AudioPlayer {
//                 audioSource: audio
//             }
//         }

//         Sticker {
//             id: stickerId
//             anchors.left: parent.left
//             anchors.leftMargin: chatBox.chatHorizontalPadding
//             anchors.top: parent.top
//             anchors.topMargin: chatBox.chatVerticalPadding
//             color: Style.current.transparent
//             container: root.container
//             contentType: root.contentType
//         }

//         MessageMouseArea {
//             anchors.fill: parent
//         }

//         RectangleCorner {
//             // TODO find a way to show the corner for stickers since they have a border
//             visible: isMessage
//         }
//     }

//     ChatTime {
//         id: chatTime
//         anchors.top: linksLoader.active ? linksLoader.bottom : chatBox.bottom
//         anchors.topMargin: 4
//         anchors.bottomMargin: Style.current.padding
//         anchors.right: linksLoader.active ? linksLoader.right : chatBox.right
//         anchors.rightMargin: root.isCurrentUser ? 5 : Style.current.padding
//     }

//     SentMessage {
//         id: sentMessage
//         visible: root.isCurrentUser && !timeout && !isExpired && isMessage && outgoingStatus !== "sent"
//         anchors.top: chatTime.top
//         anchors.bottomMargin: Style.current.padding
//         anchors.right: chatTime.left
//         anchors.rightMargin: 5
//     }

//     Retry {
//         id: retry
//         anchors.top: chatTime.top
//         anchors.right: chatTime.left
//         anchors.rightMargin: 5
//         anchors.bottomMargin: Style.current.padding
//     }

//     Loader {
//         id: linksLoader
//         active: !!root.linkUrls
//         anchors.left: !root.isCurrentUser ? chatImage.right : undefined
//         anchors.leftMargin: !root.isCurrentUser ? 8 : 0
//         anchors.right: !root.isCurrentUser ? undefined : parent.right
//         anchors.rightMargin: !root.isCurrentUser ? 0 : Style.current.padding
//         anchors.top: chatBox.bottom
//         anchors.topMargin: Style.current.halfPadding
//         anchors.bottomMargin: Style.current.halfPadding

//         sourceComponent: Component {
//             LinksMessage {
//                 linkUrls: root.linkUrls
//                 container: root.container
//                 isCurrentUser: root.isCurrentUser
//             }
//         }
//     }

//     Loader {
//         id: emojiReactionLoader
//         active: emojiReactions !== ""
//         sourceComponent: emojiReactionsComponent
//         anchors.left: !root.isCurrentUser ? chatBox.left : undefined
//         anchors.right: !root.isCurrentUser ? undefined : chatBox.right
//         anchors.top: chatBox.bottom
//         anchors.topMargin: 2
//     }

//     Component {
//         id: emojiReactionsComponent
//         EmojiReactions {}
//     }
// }

