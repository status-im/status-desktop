import QtQuick 2.13

import utils 1.0

import StatusQ.Components 0.1

import "../../shared"

Item {
    id: root

    property string chatId
    property string chatName
    property int chatType
    property string identicon
    property int letterSize: 15

    width: 40
    height: 40

    Loader {
        sourceComponent: root.chatType == Constants.chatTypeOneToOne || !!root.identicon ? imageIdenticon : letterIdenticon
        anchors.fill: parent
    }

    Component {
        id: letterIdenticon

        StatusLetterIdenticon {
            name: root.chatName
            width: parent.width
            height: parent.height
            letterSize: root.letterSize
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

