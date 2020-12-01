import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12
import QtQml 2.13
import QtGraphicalEffects 1.13

import "../imports"
import "./status"
import "../app/AppLayouts/Chat/ContactsColumn"

Item {
    id: root
    property string chatId: ""
    property string message: "Everything is connected"
    property int messageType: 1
    property int chatType: 1
    property string timestamp: "20/2/2020"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAGQAQMAAAC6caSPAAAABlBMVEXMzMz////TjRV2AAAAAWJLR0QB/wIt3gAAACpJREFUGBntwYEAAAAAw6D7Uw/gCtUAAAAAAAAAAAAAAAAAAAAAAAAAgBNPsAABAjKCqQAAAABJRU5ErkJggg=="
    property string username: "@jonas"
    property string channelName: "sic-mundus"

    property var processClick: Backpressure.oneInTime(root, 1000, function () {
        notificationSound.play()
        var w1 = winInit.createObject(null)
        w1.destroy()
    })

    Component {
        id: winInit
        Window {
            flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Popup
                   | Qt.WA_ShowWithoutActivating | Qt.BypassWindowManagerHint
            width: 1
            height: 1
            Component.onCompleted: {
                requestActivate()
                mainWin.createObject(root)
            }
        }
    }

    Component {
        id: mainWin

        Window {
            id: notificationWindowSub
            flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WA_ShowWithoutActivating | Qt.BypassWindowManagerHint
            height: channelNotif.height
            width: channelNotif.width
            x: Screen.width - (width + 50)
            y: 50
            visible: true
            color: Style.current.transparent

            StatusNotification {
                id: channelNotif
                chatId: root.chatId
                name: {
                  if (appSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous) {
                      return "Status"
                  }
                  if (root.chatType === Constants.chatTypePublic) {
                      return root.chatId
                  }
                  return root.chatType === Constants.chatTypePrivateGroupChat ? Utils.filterXSS(root.channelName) : Utils.removeStatusEns(root.username)
                }
                message: {
                    if (appSettings.notificationMessagePreviewSetting > Constants.notificationPreviewNameOnly) {
                        switch(root.messageType){
                            case Constants.imageType: return qsTr("Image");
                            case Constants.stickerType: return qsTr("Sticker");
                            default: return Emoji.parse(root.message, "26x26").replace(/\n|\r/g, ' ')
                        }
                    }
                    return qsTr("You have a new message")
                }
                chatType: root.chatType
                identicon: root.identicon

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        timer.stop()
                        notificationWindowSub.close()
                        applicationWindow.raise()
                        chatsModel.setActiveChannel(chatId)
                        applicationWindow.requestActivate()
                    }
                }

                Timer {
                    id: timer
                    interval: 4000
                    running: false
                    repeat: false
                    onTriggered: {
                        notificationWindowSub.close()
                    }
                }
                onVisibleChanged: {
                    if (visible) {
                        timer.running = true
                        if (applicationWindow.active) {
                            this.flags |= Qt.Popup
                        } else {
                            this.flags = Qt.FramelessWindowHint | Qt.WA_ShowWithoutActivating
                                        | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint
                        }
                    }
                }
            }
        }
    }

    function notifyUser(chatId, msg, messageType, chatType, timestamp, identicon, username, channelName) {
        this.chatId = chatId
        this.message = msg
        this.messageType = parseInt(messageType, 10)
        this.chatType = chatType
        this.timestamp = timestamp
        this.identicon = identicon
        this.username = username
        this.channelName = channelName
        processClick()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
