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
    property var categories: []

    id: popup
    modal: false
    width: 360
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

    Component.onCompleted: {
        var categoryNames = {"recent": 0}
        var newCategories = [[]]

        EmojiJSON.emoji_json.forEach(function (emoji) {
            if (!categoryNames[emoji.category] && categoryNames[emoji.category] !== 0) {
                categoryNames[emoji.category] = newCategories.length
                newCategories.push([])
            }

            newCategories[categoryNames[emoji.category]].push(emoji)
        })
        if (newCategories[categoryNames.recent].length === 0) {
            newCategories[categoryNames.recent].push({
                category: "recent",
                empty: true
            })
        }

        categories = newCategories
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            property int headerMargin: 8

            id: emojiHeader
            Layout.fillWidth: true
            height: searchBox.height + emojiHeader.headerMargin

            SearchBox {
               id: searchBox
               anchors.right: skinToneEmoji.left
               anchors.rightMargin: emojiHeader.headerMargin
               anchors.top: parent.top
               anchors.topMargin: emojiHeader.headerMargin
               anchors.left: parent.left
               anchors.leftMargin: emojiHeader.headerMargin
            }

            SVGImage {
                id: skinToneEmoji
                width: 22
                height: 22
                anchors.verticalCenter: searchBox.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: emojiHeader.headerMargin
                source: "../../../../imports/twemoji/26x26/1f590.png"

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: function () {
                       console.log('Change skin tone')
                    }
                }
            }
        }

        ScrollView {
            property ScrollBar vScrollBar: ScrollBar.vertical
            property var categrorySectionHeightRatios: []
            property int activeCategory: 0

            id: scrollView
            topPadding: Style.current.smallPadding
            leftPadding: Style.current.smallPadding
            rightPadding: Style.current.smallPadding / 2
            Layout.fillWidth: true
            Layout.rightMargin: Style.current.smallPadding / 2
            Layout.topMargin: Style.current.smallPadding
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.preferredHeight: 400 - Style.current.smallPadding - emojiHeader.height
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ScrollBar.vertical.onPositionChanged: function () {
                if (vScrollBar.position < categrorySectionHeightRatios[scrollView.activeCategory - 1]) {
                    scrollView.activeCategory--
                } else if (vScrollBar.position > categrorySectionHeightRatios[scrollView.activeCategory]) {
                    scrollView.activeCategory++
                }
            }

            function scrollToCategory(category) {
                if (category === 0) {
                    return vScrollBar.setPosition(0)
                }
                vScrollBar.setPosition(categrorySectionHeightRatios[category - 1])
            }

            contentHeight: {
                var totalHeight = 0
                var categoryHeights = []
                for (let i = 0; i < emojiSectionsRepeater.count; i++) {
                    totalHeight += emojiSectionsRepeater.itemAt(i).height + Style.current.padding
                    categoryHeights.push(totalHeight)
                }
                var ratios = []
                categoryHeights.forEach(function (catHeight) {
                    ratios.push(catHeight / totalHeight)
                })

                categrorySectionHeightRatios = ratios
                return totalHeight + Style.current.padding
            }

            Repeater {
                id: emojiSectionsRepeater
                model: popup.categories

                EmojiSection {}
            }
        }

        Row {
            Layout.fillWidth: true
            height: 40
            leftPadding: Style.current.smallPadding / 2
            rightPadding: Style.current.smallPadding / 2
            spacing: 0

            Repeater {
                model: EmojiJSON.emojiCategories

                EmojiCategoryButton {
                    source: `../../../img/emojiCategories/${modelData}.svg`
                    active: index === scrollView.activeCategory
                    changeCategory: function () {
                        scrollView.activeCategory = index
                        scrollView.scrollToCategory(index)
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
