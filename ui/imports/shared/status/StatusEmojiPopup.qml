import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.panels 1.0
import shared.controls 1.0

Popup {
    id: popup
    property var categories: []
    property alias searchString: searchBox.text
    property var skinColors: ["1f3fb", "1f3fc", "1f3fd", "1f3fe", "1f3ff"]
    property string emojiSize: ""

    signal emojiSelected(string emoji, bool atCu)

    modal: false
    width: 360
    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow{
            verticalOffset: 3
            radius: 8
            samples: 15
            cached: true
            color: "#22000000"
        }
    }

    function containsSkinColor(code) {
      return skinColors.some(function (color) {
        return code.includes(color)
      });
    }

    function addEmoji(emoji) {
        const MAX_EMOJI_NUMBER = 36
        const extenstionIndex = emoji.filename.lastIndexOf('.');
        let iconCodePoint = emoji.filename
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

        // Add at the  start of the list
        let recentEmojis = localAccountSensitiveSettings.recentEmojis
        if (recentEmojis === undefined) {
            recentEmojis = []
        }
        recentEmojis.unshift(emoji)
        // Remove duplicates
        recentEmojis = recentEmojis.filter(function (e, index) {
            return !recentEmojis.some(function (e2, index2) {
                return index2 < index && e2.filename === e.filename
            })
        })
        if (recentEmojis.length > MAX_EMOJI_NUMBER) {
            // remove last one
            recentEmojis.splice(MAX_EMOJI_NUMBER - 1)
        }
        emojiSectionsRepeater.itemAt(0).allEmojis = recentEmojis
        localAccountSensitiveSettings.recentEmojis = recentEmojis

        // Adding a space because otherwise, some emojis would fuse since emoji is just a string
        popup.emojiSelected(StatusQUtils.Emoji.parse(encodedIcon, popup.emojiSize || undefined) + ' ', true)
        popup.close()
    }

    function populateCategories() {
        var categoryNames = {"recent": 0}
        var newCategories = [[]]

        StatusQUtils.Emoji.emojiJSON.emoji_json.forEach(function (emoji) {
            if (!categoryNames[emoji.category] && categoryNames[emoji.category] !== 0) {
                categoryNames[emoji.category] = newCategories.length
                newCategories.push([])
            }

            var emojisWithColors = [
                        "1f64c",
                        "1f44f",
                        "1f44b",
                        "1f44d",
                        "1f44e",
                        "1f44a",
                        "270a",
                        "270c",
                        "1f44c",
                        "270b",
                        "1f450",
                        "1f4aa",
                        "1f64f",
                        "261d",
                        "1f446",
                        "1f447",
                        "1f448",
                        "1f449",
                        "1f595",
                        "1f590",
                        "1f918",
                        "1f596",
                        "270d",
                        "1f485",
                        "1f442",
                        "1f443",
                        "1f476",
                        "1f466",
                        "1f467",
                        "1f468",
                        "1f469",
                        "1f471",
                        "1f474",
                        "1f475",
                        "1f472",
                        "1f473",
                        "1f46e",
                        "1f477",
                        "1f482",
                        "1f385",
                        "1f47c",
                        "1f478",
                        "1f470",
                        "1f6b6",
                        "1f3c3",
                        "1f483",
                        "1f647",
                        "1f481",
                        "1f645",
                        "1f646",
                        "1f64b",
                        "1f64e",
                        "1f64d",
                        "1f487",
                        "1f486",
                        "1f6a3",
                        "1f3ca",
                        "1f3c4",
                        "1f6c0",
                        "26f9",
                        "1f3cb",
                        "1f6b4",
                        "1f6b5",
                        "1f3c7",
                        "1f575"
                    ]


            if (localAccountSensitiveSettings.skinColor !== "") {
                if (emoji.unicode.includes(localAccountSensitiveSettings.skinColor)) {
                    newCategories[categoryNames[emoji.category]].push(Object.assign({}, emoji, {filename: emoji.unicode}));
                } else {
                    if (!emojisWithColors.includes(emoji.unicode) && !containsSkinColor(emoji.unicode))  {
                        newCategories[categoryNames[emoji.category]].push(Object.assign({}, emoji, {filename: emoji.unicode}));
                    }
                }
            } else {
                if (!containsSkinColor(emoji.unicode)) {
                    newCategories[categoryNames[emoji.category]].push(Object.assign({}, emoji, {filename: emoji.unicode}));
                }
            }
        })

        if (newCategories[categoryNames.recent].length === 0) {
            newCategories[categoryNames.recent].push({category: "recent", empty: true })
        }

        categories = newCategories;

        const recent = localAccountSensitiveSettings.recentEmojis;
        if (!!recent) {
            emojiSectionsRepeater.itemAt(0).allEmojis = recent;
        }
    }

    onOpened: {
        searchBox.text = ""
        searchBox.input.edit.forceActiveFocus()
        Qt.callLater(populateCategories);
    }

    onClosed: {
        popup.emojiSize = ""
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.smallPadding

        Item {
            readonly property int headerMargin: 8

            id: emojiHeader
            Layout.fillWidth: true
            height: searchBox.height + emojiHeader.headerMargin

            SearchBox {
                input.edit.objectName: "StatusEmojiPopup_searchBox"
                id: searchBox
                anchors.right: skinToneEmoji.left
                anchors.rightMargin: emojiHeader.headerMargin
                anchors.top: parent.top
                anchors.topMargin: emojiHeader.headerMargin
                anchors.left: parent.left
                anchors.leftMargin: emojiHeader.headerMargin
            }

            Row {
                id: skinToneEmoji
                property bool expandSkinColorOptions: false
                width: expandSkinColorOptions ? (22 * skinColorEmojiRepeater.count) : 22
                height: 22
                opacity: expandSkinColorOptions ? 1.0 : 0.0
                Behavior on width { NumberAnimation  { duration: 400 } }
                Behavior on opacity { NumberAnimation  { duration: 200 } }
                visible: (opacity > 0.1)
                anchors.verticalCenter: searchBox.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: emojiHeader.headerMargin
                Repeater {
                    id: skinColorEmojiRepeater
                    model: ["1f590-1f3fb", "1f590-1f3fc", "1f590-1f3fd", "1f590-1f3fe", "1f590-1f3ff", "1f590"]
                    delegate: StatusEmoji {
                        width: 22
                        height: 22
                        emojiId: modelData
                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            onClicked: {
                                localAccountSensitiveSettings.skinColor = (index === 5) ? "" : modelData.split("-")[1];
                                popup.populateCategories();
                                skinToneEmoji.expandSkinColorOptions = false;
                            }
                        }
                    }
                }
            }

            StatusEmoji {
                width: 22
                height: 22
                anchors.verticalCenter: searchBox.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: emojiHeader.headerMargin
                visible: !skinToneEmoji.expandSkinColorOptions
                emojiId: "1f590" + ((localAccountSensitiveSettings.skinColor !== "" && visible) ? ("-" + localAccountSensitiveSettings.skinColor) : "")
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        skinToneEmoji.expandSkinColorOptions = true;
                    }
                }
            }
        }

        StatusScrollView {
            readonly property ScrollBar vScrollBar: ScrollBar.vertical
            property var categrorySectionHeightRatios: []
            property int activeCategory: 0

            id: scrollView
            padding: Style.current.smallPadding
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            contentWidth: availableWidth

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
                    totalHeight += emojiSectionsRepeater.itemAt(i).height
                    categoryHeights.push(totalHeight)
                }
                var ratios = []
                categoryHeights.forEach(function (catHeight) {
                    ratios.push(catHeight / totalHeight)
                })

                categrorySectionHeightRatios = ratios
                return totalHeight - scrollView.topPadding - scrollView.bottomPadding
            }

            Repeater {
                id: emojiSectionsRepeater
                model: popup.categories

                StatusEmojiSection {
                    width: scrollView.availableWidth
                    searchString: popup.searchString
                    addEmoji: popup.addEmoji
                }
            }
        }

        Row {
            Layout.fillWidth: true
            height: 40
            spacing: 0

            Repeater {
                model: StatusQUtils.Emoji.emojiJSON.emojiCategories

                StatusTabBarIconButton {
                    icon.name: modelData
                    highlighted: index === scrollView.activeCategory
                    onClicked: {
                        scrollView.activeCategory = index
                        scrollView.scrollToCategory(index)
                    }
                }
            }
        }
    }
}
