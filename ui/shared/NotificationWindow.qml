import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12
import QtQml 2.13
import QtGraphicalEffects 1.13

import "../imports"
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

    property var processClick: Backpressure.oneInTime(root, 1000, function () {
        notificationSound.play()
        var w1 = winInit.createObject(null)
        w1.destroy()
    })

    Component {
        id: winInit
        Window {
            flags: Qt.WindowStaysOnTopHint | Qt.WindowStaysOnTopHint | Qt.Popup
                   | Qt.WA_ShowWithoutActivating | Qt.WindowStaysOnTopHint
                   | Qt.BypassWindowManagerHint | Qt.WindowStaysOnTopHint
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
            flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                   | Qt.WA_ShowWithoutActivating | Qt.BypassWindowManagerHint
                   | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint
            width: 300 + 10
            height: channelNotif.height + 10
            x: Screen.width - (width + 50)
            y: 50
            visible: true
            color: Style.current.transparent

            Channel {
                id: channelNotif
                name: root.chatType === Constants.chatTypeOneToOne ? root.username : root.chatId
                lastMessage: root.message
                timestamp: root.timestamp
                chatType: root.chatType
                unviewedMessagesCount: "0"
                hasMentions: false
                contentType: root.messageType
                identicon: root.identicon
                searchStr: ""
                isCompact: false
                color: Style.current.background
                anchors.rightMargin: 10
            }
            DropShadow {
                anchors.fill: channelNotif
                horizontalOffset: 2
                verticalOffset: 5
                visible: channelNotif.visible
                source: channelNotif
                radius: 10
                samples: 15
                color: "#ad000000"
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    timer.stop()
                    notificationWindowSub.close()
                    applicationWindow.raise()
                    chatsModel.setActiveChannel(chatId)
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
                        this.flags = Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                             | Qt.WA_ShowWithoutActivating | Qt.BypassWindowManagerHint
                             | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint
                    }
                }
            }
        }
    }

    function notifyUser(chatId, msg, messageType, chatType, timestamp, identicon, username) {
        this.chatId = chatId
        this.message = msg
        this.messageType = parseInt(messageType, 10)
        this.chatType = chatType
        this.timestamp = timestamp
        this.identicon = identicon
        this.username = username
        processClick()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

