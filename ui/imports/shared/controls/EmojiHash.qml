import QtQuick 2.13
import QtQuick.Layouts 1.14
import StatusQ.Core.Utils 0.1 as StatusQUtils
import utils 1.0

Item {
    id: root
    property string publicKey
    property string size: "14x14"
    property var emojiHashFirstRow
    property var emojiHashSecondRow
    property real rowPadding: 0
    property real columnPadding: 0
    property real wrapperWidth: 14
    property real wrapperHeight: 14

    implicitHeight: 60

    Component.onCompleted: {
        const dimensions = size.split("x")
        wrapperWidth = dimensions[0]
        wrapperHeight = dimensions[1]
    }
    onPublicKeyChanged: {
        const emojiHash = Utils.getEmojiHashAsJson(publicKey)
        const i = Math.ceil(emojiHash.length / 2)
        emojiHashFirstRow= emojiHash.slice(0, i)
        emojiHashSecondRow = emojiHash.slice(i)
    }

    Column {
        id: column
        anchors {
            fill: parent
        }
        spacing: root.columnPadding
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.rowPadding
            Repeater {
                model: emojiHashFirstRow
                delegate: Item {
                    width: root.wrapperWidth
                    height: root.wrapperHeight
                    Text {
                        anchors.centerIn: parent
                        text: StatusQUtils.Emoji.parse(modelData, root.size)
                    }
                }
            }
        }
        Row {
            spacing: root.rowPadding
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: emojiHashSecondRow
                delegate: Item {
                    width: root.wrapperWidth
                    height: root.wrapperHeight
                    Text {
                        anchors.centerIn: parent
                        text: StatusQUtils.Emoji.parse(modelData, root.size)
                    }
                }
            }
        }
    }
}
