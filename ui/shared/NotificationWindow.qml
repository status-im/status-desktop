import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.12
import QtQml 2.13

import "../imports"

Item {
    id: root
    property var chatId: ""
    property var message: "hello"
    property var processClick : Backpressure.oneInTime(root, 1000, function() {
        notificationSound.play()
        var w1 = winInit.createObject(null)
        w1.destroy()
    });

    Component {
        id: winInit
        Window {
            flags: Qt.WindowStaysOnTopHint | Qt.WindowStaysOnTopHint | Qt.Popup | Qt.WA_ShowWithoutActivating | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint | Qt.WindowStaysOnTopHint
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
            flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WA_ShowWithoutActivating | Qt.BypassWindowManagerHint | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint
            x: Screen.width - 250
            y: 50
            width: 200
            height: 100
            visible: true

            Rectangle {
                anchors.fill: parent
                color: "white"
                Text {
                    anchors.centerIn: parent
                    text: message
                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: {
                            timer.stop()
                            notificationWindowSub.close()
                            mainWin.destroy()
                            applicationWindow.raise()
                            chatsModel.setActiveChannel(chatId);
                        }
                    }
                }
            }

            Timer {
                id: timer
                interval: 4000;
                running: false;
                repeat: false
                onTriggered: {
                  notificationWindowSub.close()
                }
            }
            onVisibleChanged: {
                if(visible) {
                    timer.running = true;
                    if (applicationWindow.active) {
                        this.flags |= Qt.Popup
                    } else {
                        this.flags = Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WA_ShowWithoutActivating | Qt.BypassWindowManagerHint | Qt.WindowStaysOnTopHint | Qt.BypassWindowManagerHint
                    }

                }
            }
        }
    }

    function notifyUser(chatId, msg) {
        this.chatId = chatId
        this.message = msg
        processClick()
   }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
