import QtQuick 2.13
import QtQuick.Layouts 1.3
import "../../imports"
import "../../shared"


Item {
    property string searchString: ""
    property string searchStringLowercase: searchString.toLowerCase()
    property int imageWidth: 26
    property int imageMargin: 4
    property var emojis: []
    property var allEmojis: modelData
    property var addEmoji: function () {}

    id: emojiSection
    visible: emojis.length > 0 || !!(modelData && modelData.length && modelData[0].empty && searchString === "")

    anchors.top: index === 0 ? parent.top : parent.children[index - 1].bottom
    anchors.topMargin: index === 0 ? 0 : Style.current.padding

    width: parent.width
    // childrenRect caused a binding loop here
      height: this.visible ? emojiGrid.height + categoryText.height + noRecentText.height + Style.current.padding : 0

    StyledText {
        id: categoryText
        text: modelData && modelData.length ? modelData[0].category.toUpperCase() : ""
        color: Style.current.darkGrey
        font.pixelSize: 13
    }

    StyledText {
        id: noRecentText
        visible: !!(allEmojis && allEmojis.length && allEmojis[0].empty)
        //% "No recent emojis"
        text: qsTrId("no-recent-emojis")
        color: Style.current.darkGrey
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
        if (this.allEmojis[0].empty) {
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

                SVGImage {
                    width: emojiSection.imageWidth
                    height: emojiSection.imageWidth
                    source: "../../imports/twemoji/svg/" + modelData.filename + "?22x22"

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
