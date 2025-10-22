import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils

import utils

import shared.controls

import SortFilterProxyModel

StatusDropdown {
    id: root

    required property StatusEmojiModel emojiModel
    required property var settings

    property alias searchString: searchBox.text
    property string emojiSize: ""

    signal emojiSelected(string emoji, bool atCu, string hexcode)

    width: 360
    padding: 0

    function addEmoji(hexcode) {
        const extensionIndex = hexcode.lastIndexOf('.');
        let iconCodePoint = hexcode
        if (extensionIndex > -1) {
            iconCodePoint = iconCodePoint.substring(0, extensionIndex)
        }

        const encodedIcon = StatusQUtils.Emoji.getEmojiCodepoint(iconCodePoint)

        // Adding a space because otherwise, some emojis would fuse since emoji is just a string
        root.emojiSelected(StatusQUtils.Emoji.parse(encodedIcon, root.emojiSize || undefined) + ' ', true, hexcode)
        root.close()
    }

    Component.onCompleted: {
        root.emojiModel.recentEmojis = settings.recentEmojis
    }

    onOpened: {
        if (!StatusQUtils.Utils.isMobile)
            searchBox.input.edit.forceActiveFocus()
        emojiGrid.positionViewAtBeginning()
    }

    onClosed: {
        const recent = root.emojiModel.recentEmojis
        if (recent.length)
            settings.recentEmojis = recent
        searchBox.text = ""
        root.emojiSize = ""
        skinToneEmoji.expandSkinColorOptions = false
    }

    QtObject {
        id: d

        readonly property string searchStringLowercase: searchBox.text.toLowerCase()
        readonly property int headerMargin: 8
        readonly property int imageWidth: 26
        readonly property int imageMargin: 4

        readonly property var filteredModel: SortFilterProxyModel {
            sourceModel: root.emojiModel

            filters: [
                FastExpressionFilter {
                    expression: {
                        if (model.category === root.emojiModel.recentCategoryName) // don't show/duplicate recents when searching
                            return false

                        d.searchStringLowercase
                        return model.name.toLowerCase().includes(d.searchStringLowercase) ||
                                model.shortname.toLowerCase().includes(d.searchStringLowercase) ||
                                model.aliases.some(a => a.includes(d.searchStringLowercase)) ||
                                model.keywords.some(k => k.includes(d.searchStringLowercase))
                    }
                    expectedRoles: ["name", "shortname", "aliases", "keywords", "category"]
                    enabled: !!d.searchStringLowercase
                },
                AnyOf {
                    ValueFilter {
                        roleName: "skinColor"
                        value: ""
                    }
                    ValueFilter {
                        roleName: "skinColor"
                        value: root.emojiModel.baseSkinColorName
                    }
                    enabled: settings.skinColor === ""
                },
                AnyOf {
                    ValueFilter {
                        roleName: "skinColor"
                        value: ""
                    }
                    ValueFilter {
                        roleName: "skinColor"
                        value: settings.skinColor
                    }
                    enabled: settings.skinColor !== ""
                }
            ]

            sorters: RoleSorter {
                roleName: "emoji_order"
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: searchBox.height + d.headerMargin

            SearchBox {
                input.edit.objectName: "StatusEmojiPopup_searchBox"
                id: searchBox
                anchors.right: skinToneEmoji.left
                anchors.rightMargin: d.headerMargin
                anchors.top: parent.top
                anchors.topMargin: d.headerMargin
                anchors.left: parent.left
                anchors.leftMargin: d.headerMargin
                minimumHeight: 36
                maximumHeight: 36
                input.topPadding: 0
                input.bottomPadding: 0
            }

            Row {
                id: skinToneEmoji
                property bool expandSkinColorOptions: false
                clip: true
                width: expandSkinColorOptions ? (22 * skinColorEmojiRepeater.count) : 22
                height: 22
                opacity: expandSkinColorOptions ? 1.0 : 0.0
                Behavior on width { NumberAnimation  { duration: 400 } }
                Behavior on opacity { NumberAnimation  { duration: 200 } }
                visible: (opacity > 0.1)
                anchors.verticalCenter: searchBox.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: d.headerMargin
                Repeater {
                    id: skinColorEmojiRepeater
                    model: ["1f590-1f3fb", "1f590-1f3fc", "1f590-1f3fd", "1f590-1f3fe", "1f590-1f3ff", "1f590"]
                    delegate: StatusEmoji {
                        width: 22
                        height: 22
                        emojiId: modelData
                        StatusMouseArea {
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            onClicked: {
                                settings.skinColor = (index === 5) ? "" : modelData.split("-")[1];
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
                anchors.rightMargin: d.headerMargin
                visible: !skinToneEmoji.expandSkinColorOptions
                emojiId: "1f590" + ((settings.skinColor !== "" && visible) ? ("-" + settings.skinColor) : "")
                StatusMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        skinToneEmoji.expandSkinColorOptions = true;
                    }
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: d.headerMargin
            Layout.topMargin: 8
            Layout.bottomMargin: 4
            font.weight: Font.Medium
            color: Theme.palette.secondaryText
            font.pixelSize: Theme.additionalTextSize
            text: d.searchStringLowercase ? (d.filteredModel.count ? qsTr("Search Results") : qsTr("No results found"))
                                          : emojiGrid.currentCategory
            font.capitalization: Font.AllUppercase
        }

        StatusGridView {
            id: emojiGrid
            Layout.fillWidth: true
            Layout.preferredHeight: root.availableHeight || contentHeight
            Layout.fillHeight: true
            Layout.leftMargin: d.headerMargin

            readonly property string currentCategory: {
                const item = emojiGrid.itemAt(contentX, contentY + (contentY !== originY ? cellHeight : 0)) // taking the 2nd row; 1st might be split between 2 categories
                return !!item ? item.category : root.emojiModel.recentCategoryName
            }
            readonly property string currentCategoryIndex: root.emojiModel.categories.indexOf(currentCategory)

            model: d.filteredModel

            cellWidth: d.imageWidth + d.imageMargin * 2
            cellHeight: d.imageWidth + d.imageMargin * 2

            ScrollBar.vertical: StatusScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Item {
                readonly property string category: model.category

                width: emojiGrid.cellWidth
                height: emojiGrid.cellHeight

                StatusEmoji {
                    objectName: "statusEmoji_" + model.shortname.replace(/:/g, "")
                    anchors.centerIn: parent
                    width: d.imageWidth
                    height: d.imageWidth
                    emojiId: model.unicode

                    StatusMouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: root.addEmoji(model.unicode)
                    }
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
                    highlighted: !!d.searchStringLowercase ? index === 0 : index == emojiGrid.currentCategoryIndex
                    onClicked: {
                        const offset = d.filteredModel.mapFromSource(root.emojiModel.getCategoryOffset(index))
                        emojiGrid.positionViewAtIndex(offset, GridView.Beginning)
                    }
                }
            }
        }
    }
}
