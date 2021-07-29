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
    property string name: "channel name"
    property string message: "Everything is connected"
    property int chatType: 1
    property var onClick
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAGQAQMAAAC6caSPAAAABlBMVEXMzMz////TjRV2AAAAAWJLR0QB/wIt3gAAACpJREFUGBntwYEAAAAAw6D7Uw/gCtUAAAAAAAAAAAAAAAAAAAAAAAAAgBNPsAABAjKCqQAAAABJRU5ErkJggg=="

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
                name: root.name
                message: root.message
                chatType: root.chatType
                identicon: root.identicon

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        timer.stop()
                        notificationWindowSub.close()
                        root.onClick(root.chatId)
                        notificationWindowSub.destroy()
                    }
                }

                Timer {
                    id: timer
                    interval: Constants.notificationPopupTTL
                    running: true
                    repeat: false
                    onTriggered: {
                        notificationWindowSub.close()
                        notificationWindowSub.destroy()
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

    function notifyUser(chatId, name, msg, chatType, identicon, onClick) {
        this.chatId = chatId
        this.name = name
        this.message = msg
        this.chatType = chatType
        this.identicon = identicon
        this.onClick = onClick
        processClick()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
