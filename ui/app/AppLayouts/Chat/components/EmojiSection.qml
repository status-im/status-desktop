import QtQuick 2.13
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"


Item {
    property string searchString: ""
    property string searchStringLowercase: searchString.toLowerCase()
    property int imageWidth: 26
    property int imageMargin: 4
    property var emojis: []
    property var allEmojis: []

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
        visible: !!(modelData && modelData.length && modelData[0].empty)
        text: qsTr("No recent emojis")
        color: Style.current.darkGrey
        font.pixelSize: 10
        anchors.top: categoryText.bottom
        anchors.topMargin: Style.current.smallPadding
    }

    onSearchStringLowercaseChanged: {
        if (emojiSection.searchStringLowercase === "") {
            this.emojis = this.allEmojis
            return
        }
        this.emojis = this.allEmojis.filter(function (emoji) {
            return emoji.name.includes(emojiSection.searchStringLowercase) ||
                    emoji.shortname.includes(emojiSection.searchStringLowercase) ||
                    emoji.aliases.some(a => a.includes(emojiSection.searchStringLowercase))
        })
    }

    Component.onCompleted: {
        var myEmojis = []
        modelData.forEach(function (emoji) {
            if (emoji.empty) {
                return
            }
            myEmojis.push({
                              filename: emoji.unicode + '.png',
                              name: emoji.name,
                              shortname: emoji.shortname,
                              name: emoji.name,
                              aliases: emoji.aliases
                          })
        })
        // We use two arrays for filtering purposes
        this.emojis = myEmojis
        this.allEmojis = myEmojis
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
                    source: "../../../../imports/twemoji/26x26/" + modelData.filename

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: {
                            const extenstionIndex = modelData.filename.lastIndexOf('.');
                            let iconCodePoint = modelData.filename
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
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:440;width:360}
}
##^##*/
