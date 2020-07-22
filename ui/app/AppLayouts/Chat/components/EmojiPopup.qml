import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../../../imports"
import "../../../../shared"
import "../ChatColumn/samples"

import "./emojiList.js" as EmojiJSON

Popup {
    property var addToChat: function () {}

    id: popup
    modal: false
    property int selectedPackId
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow{
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    ListModel {
        id: emojiModel
    }

    Component.onCompleted: {
        EmojiJSON.emoji_json.forEach(function (emoji) {
            emojiModel.append({filename: emoji})
        })
    }

    contentItem: ColumnLayout {
        parent: popup
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            Layout.topMargin: 4
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: 400 - 4

            GridView {
                property int imageWidth: 26
                property int imageMargin: 4

                id: emojiGrid
                visible: count > 0
                anchors.fill: parent
                cellWidth: imageWidth + emojiGrid.imageMargin * 2
                cellHeight: imageWidth + emojiGrid.imageMargin * 2
                model: emojiModel
                focus: true
                clip: true
                delegate: Item {
                    width: emojiGrid.cellWidth
                    height: emojiGrid.cellHeight
                    Column {
                        anchors.fill: parent
                        anchors.topMargin: emojiGrid.imageMargin
                        anchors.leftMargin: emojiGrid.imageMargin
                        SVGImage {
                            width: emojiGrid.imageWidth
                            height: emojiGrid.imageWidth
                            source: "../../../../imports/twemoji/26x26/" + filename
                            // fillMode: Image.PreserveAspectFit
                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                onClicked: {
                                    const extenstionIndex = filename.lastIndexOf('.');
                                    let iconCodePoint = filename
                                    if (extenstionIndex > -1) {
                                        iconCodePoint = iconCodePoint.substring(0, extenstionIndex)
                                    }

                                    // Split the filename to get all the parts and then encode them from hex to utf8
                                    const splitCodePoint = iconCodePoint.split('-')
                                    let codePointParts = []
                                    splitCodePoint.forEach(function (codePoint) {
                                        codePointParts.push(`0x${codePoint}`)
                                    })
                                    const encodedIcon = String.fromCodePoint(...codePointParts);
                                    popup.addToChat(encodedIcon + ' ') // Adding a space because otherwise, some emojis would fuse since it's just an emoji is just a string
                                    popup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:440;width:360}
}
##^##*/
