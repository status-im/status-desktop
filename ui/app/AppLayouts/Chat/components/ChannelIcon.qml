import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    property string channelName
    property int channelType
    property string channelIdenticon
    readonly property int defaultFontSize: 21
    property int fontSize: defaultFontSize
    id: contactImage
    width: 36
    height: 36

    Loader {
        sourceComponent: channelType == Constants.chatTypeOneToOne ? imageIdenticon : letterIdenticon
        anchors.fill: parent
    }

    Component {
        id: letterIdenticon
        Rectangle {
            width: contactImage.width
            height: contactImage.height
            radius: 50
            color: {
                const color = chatsModel.getChannelColor(channelName)
                if (!color) {
                    return Style.current.transparent
                }
                return color
            }

            StyledText {
                text: {
                    if (channelType == Constants.chatTypeOneToOne) {
                        return channelName
                    } else {
                        return (channelName.charAt(0) == "#" ? channelName.charAt(1) : channelName.charAt(0)).toUpperCase()
                    }
                }
                opacity: 0.7
                font.weight: Font.Bold
                font.pixelSize: fontSize
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Component {
        id: imageIdenticon
        Rectangle {
            width: contactImage.width ? contactImage.width : 40
            height: contactImage.height ? contactImage.height : 40
            radius: 50
            border.color: Style.current.border
            border.width: 1
            color: Style.current.background
            SVGImage {
                width: contactImage.width ? contactImage.width : 40
                height: contactImage.height ? contactImage.height : 40
                fillMode: Image.PreserveAspectFit
                source: channelIdenticon
            }
        }
    }
}
