import QtQuick 2.13
import "../../imports"
import "../../shared"
import "../../shared/status"

Item {
    id: root

    property string chatName
    property int chatType
    property string identicon

    width: 40
    height: 40

    Loader {
        sourceComponent: root.chatType == Constants.chatTypeOneToOne || !!root.identicon ? imageIdenticon : letterIdenticon
        anchors.fill: parent
    }

    Component {
        id: letterIdenticon

        StatusLetterIdenticon {
            chatName: root.chatName
            width: parent.width
            height: parent.height
        }
    }

    Component {
        id: imageIdenticon

        StatusImageIdenticon {
            source: root.identicon
            width: parent.width
            height: parent.height
        }
    }
}

