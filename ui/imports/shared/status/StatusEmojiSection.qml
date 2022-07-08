import QtQuick 2.13
import QtQuick.Layouts 1.3

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Components 0.1

Item {
    id: emojiSection
    property string searchString: ""
    property string searchStringLowercase: searchString.toLowerCase()
    property int imageWidth: 26
    property int imageMargin: 4
    property var emojis: []
    property var allEmojis: modelData
    property var addEmoji: function () {}

    visible: emojis.length > 0 || !!(modelData && modelData.length && modelData[0].empty && searchString === "")

    anchors.top: index === 0 ? parent.top : parent.children[index - 1].bottom
    anchors.topMargin: 0

    width: parent.width
    // childrenRect caused a binding loop here
      height: this.visible ? emojiGrid.height + categoryText.height + noRecentText.height + Style.current.padding : 0

    StyledText {
        id: categoryText
        text: modelData && modelData.length ? modelData[0].category.toUpperCase() : ""
        color: Style.current.secondaryText
        font.pixelSize: 13
    }

    StyledText {
        id: noRecentText
        visible: !!(allEmojis && allEmojis.length && allEmojis[0].empty)
        text: qsTr("No recent emojis")
        color: Style.current.secondaryText
        font.pixelSize: 10
        anchors.top: categoryText.bottom
        anchors.topMargin: Style.current.smallPadding
    }

    onSearchStringLowercaseChanged: {
        if (emojiSection.searchStringLowercase === "") {
            this.emojis = allEmojis
            return
        }
        this.emojis = modelData.filter(function (emoji) {
            if (emoji.empty) {
                return false
            }
            return emoji.name.includes(emojiSection.searchStringLowercase) ||
                    emoji.shortname.includes(emojiSection.searchStringLowercase) ||
                    emoji.aliases.some(a => a.includes(emojiSection.searchStringLowercase))
        })
    }

    onAllEmojisChanged: {
        if (!!emojiSection.allEmojis[0] && this.allEmojis[0].empty) {
            return
        }
        this.emojis = this.allEmojis
    }

    GridView {
        id: emojiGrid
        anchors.top: categoryText.bottom
        anchors.topMargin: Style.current.smallPadding
        width: parent.width
        height: childrenRect.height
        visible: count > 0
        cellWidth: emojiSection.imageWidth + emojiSection.imageMargin * 2
        cellHeight: emojiSection.imageWidth + emojiSection.imageMargin * 2
        model: emojiSection.emojis
        focus: true
        clip: true
        interactive: false

        delegate: Item {
            id: emojiContainer
            width: emojiGrid.cellWidth
            height: emojiGrid.cellHeight

            Column {
                anchors.fill: parent
                anchors.topMargin: emojiSection.imageMargin
                anchors.leftMargin: emojiSection.imageMargin

                StatusEmoji {
                    width: emojiSection.imageWidth
                    height: emojiSection.imageWidth
                    emojiId: modelData.filename

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: {
                            emojiSection.addEmoji(modelData)
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
