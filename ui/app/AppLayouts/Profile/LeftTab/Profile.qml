import QtGraphicalEffects 1.12
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "../../../../imports"

Rectangle {
    property string username: "Jotaro Kujo"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAhklEQVR4nOzWwQ1AQBgFYUQvelKHMtShJ9VwFyvrsExe5jvKXiYv+WPoQhhCYwiNITSG0MSEjLUPt3097r7P09L/8f4qZhFDaAyhqboIT76+TiUxixhCYwhN9b/WW6Xr1ErMIobQGEJjCI0hNIbQGEJjCI0haiRmEUNoDKExhMYQmjMAAP//B2kXcP2uDV8AAAAASUVORK5CYII="
    property string pubkey: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    id: profileHeaderContent
    height: parent.height
    Layout.fillWidth: true

    Item {
        id: profileImgNameContainer
        width: profileHeaderContent.width
        height: profileHeaderContent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        Image {
            id: profileImg
            source: identicon
            width: 80
            height: 80
            fillMode: Image.PreserveAspectCrop
            anchors.horizontalCenter: parent.horizontalCenter

            property bool rounded: true
            property bool adapt: false
            y: 78

            layer.enabled: rounded
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: profileImg.width
                    height: profileImg.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: profileImg.adapt ? profileImg.width : Math.min(profileImg.width, profileImg.height)
                        height: profileImg.adapt ? profileImg.height : width
                        radius: Math.min(width, height)
                    }
                }
            }
        }

        Text {
            id: profileName
            text: username
            anchors.top: profileImg.bottom
            anchors.topMargin: 10
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Medium
            font.pixelSize: 20
        }
        Text {
            id: pubkeyText
            text: pubkey
            width: 208
            elide: Text.ElideMiddle
            anchors.top: profileName.bottom
            anchors.topMargin: 10
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Medium
            font.pixelSize: 20
        }
    }
}
