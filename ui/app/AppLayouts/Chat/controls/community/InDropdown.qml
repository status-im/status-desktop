import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0

import SortFilterProxyModel 0.2

StatusDropdown {
    id: root

    property string communityName
    property string communityImage
    property color communityColor

    property var model

    property int acceptMode: InDropdown.AcceptMode.Add

    enum AcceptMode {
        Add, Update
    }

    width: 289
    padding: 8

    // force keeping within the bounds of the enclosing window
    margins: 0

    signal addChannelClicked
    signal communitySelected
    signal channelsSelected(var channels)

    function setSelectedChannels(channels) {
        d.setSelectedChannels(channels)
    }

    onAboutToHide: searcher.text = ""
    onAboutToShow: scrollView.Layout.preferredHeight = Math.min(
                       scrollView.implicitHeight, 420)

    QtObject {
        id: d

        readonly property var selectedChannels: new Map()

        signal setSelectedChannels(var channels)

        function search(text, searcherText) {
            return text.toLowerCase().includes(searcherText.toLowerCase())
        }

        function resolveEmoji(emoji) {
            return !!emoji ? emoji : ""
        }

        function resolveColor(color, colorId) {
            return !!color ? color : Theme.palette.userCustomizationColors[colorId]
        }

        function addToSelectedChannels(model) {
            selectedChannels.set(model.itemId, {
                itemId: model.itemId,
                name: model.name,
                color: d.resolveColor(model.color, model.colorId),
                emoji: d.resolveEmoji(model.emoji)
            })
        }

        function removeFromSelectedChannels(model) {
            selectedChannels.delete(model.itemId)
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        spacing: 0

        SearchBox {
            id: searcher

            Layout.fillWidth: true

            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36
            maximumHeight: 36
        }

        StatusListItem {
            Layout.fillWidth: true
            Layout.topMargin: 9
            Layout.preferredHeight: 44


            title: root.communityName
            subTitle: qsTr("Community")

            asset.name:  root.communityImage
            asset.color: root.communityColor
            asset.isImage: true
            asset.width: 32
            asset.height: 32
            asset.isLetterIdenticon: !asset.name
            asset.charactersLen: 2
            asset.letterSize: 15

            leftPadding: 8
            rightPadding: 6

            statusListItemTitleArea.anchors.leftMargin: 8
            statusListItemTitle.font.pixelSize: 13
            statusListItemTitle.font.weight: Font.Medium

            statusListItemSubTitle.font.pixelSize: 12

            components: [
                StatusRadioButton {
                    id: radioButton

                    size: StatusRadioButton.Size.Small
                    rightPadding: 0
                }
            ]

            // using MouseArea instead of build-in 'clicked' signal to avoid
            // intercepting event by the StatusRadioButton
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    radioButton.toggle()
                    radioButton.toggled()
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        StatusMenuSeparator {
            Layout.fillWidth: true
            Layout.topMargin: 4 - implicitHeight / 2
            Layout.bottomMargin: 4 - implicitHeight / 2
        }

        StatusScrollView {
            id: scrollView

            Layout.fillWidth: true
            Layout.bottomMargin: 9

            padding: 0

            ColumnLayout {
                id: scollableColumn

                spacing: 0
                width: scrollView.width

                StatusIconTextButton {
                    Layout.preferredHeight: 36

                    leftPadding: 8
                    spacing: 8
                    statusIcon: "add"
                    icon.width: 16
                    icon.height: 16
                    iconRotation: 0
                    text: qsTr("Add channel")
                    onClicked: root.addChannelClicked()
                }

                Repeater {
                    id: topRepeater

                    model: SortFilterProxyModel {
                        id: topLevelModel

                        sourceModel: root.model

                        sorters: [
                            RoleSorter { roleName: "isCategory" },
                            RoleSorter { roleName: "position" }
                        ]
                    }

                    ColumnLayout {
                        id: column

                        Layout.fillWidth: true
                        spacing: 0

                        readonly property var topModel: model
                        readonly property alias checkBox: loader.item
                        property int checkedCount: 0

                        visible: {
                            if (!model.isCategory)
                                return d.search(model.name, searcher.text)
                                        || checkBox.checked

                            if (checkedCount > 0)
                                return true

                            const subItemsCount = subItemsRepeater.count

                            for (let i = 0; i < subItemsCount; i++)
                                if (subItemsRepeater.itemAt(i).show)
                                    return true

                            return false
                        }

                        Loader {
                            id: loader

                            Layout.fillWidth: true
                            Layout.topMargin: model.isCategory ? 9 : 0

                            sourceComponent: model.isCategory
                                             ? communityCategoryDelegate
                                             : communityDelegate

                            Connections {
                                target: radioButton

                                function onToggled() {
                                    const checkBox = loader.item.checkBox
                                    checkBox.checked = false
                                    checkBox.onToggled()

                                }
                            }

                            Component {
                                id: communityDelegate

                                CommunityListItem {
                                    id: communityItem

                                    title: "#" + model.name

                                    asset.name: model.icon
                                    asset.emoji: d.resolveEmoji(model.emoji)
                                    asset.color: d.resolveColor(model.color,
                                                                model.colorId)

                                    checkBox.onToggled: {
                                        if (checked)
                                            radioButton.checked = false
                                    }

                                    checkBox.onCheckedChanged: {
                                        if (checkBox.checked)
                                            d.addToSelectedChannels(model)
                                        else
                                            d.removeFromSelectedChannels(model)
                                    }

                                    Connections {
                                        target: d

                                        function onSetSelectedChannels(channels) {
                                            communityItem.checked = channels.includes(
                                                        model.itemId)
                                        }
                                    }
                                }
                            }

                            Component {
                                id: communityCategoryDelegate

                                CommunityCategoryListItem {
                                    title: model.name

                                    checkState: {
                                        if (checkedCount === model.subItems.count)
                                            return Qt.Checked
                                        else if (checkedCount === 0)
                                            return Qt.Unchecked

                                        return Qt.PartiallyChecked
                                    }

                                    checkBox.onToggled: {
                                        if (checked)
                                            radioButton.checked = false

                                        subItemsRepeater.setAll(checkState)
                                    }
                                }
                            }
                        }

                        Repeater {
                            id: subItemsRepeater

                            model: SortFilterProxyModel {
                                sourceModel: topModel.isCategory ? topModel.subItems : null
                                sorters: RoleSorter { roleName: "position" }
                            }

                            function setAll(checkState) {
                                const subItemsCount = count

                                for (let i = 0; i < subItemsCount; i++) {
                                    itemAt(i).checkState = checkState
                                }
                            }

                            CommunityListItem {
                                id: communitySubItem

                                Layout.fillWidth: true

                                readonly property bool show: d.search(model.name, searcher.text)
                                                             || checked

                                visible: show

                                title: "#" + model.name

                                asset.name: model.icon
                                asset.emoji: d.resolveEmoji(model.emoji)
                                asset.color: d.resolveColor(model.color,
                                                            model.colorId)

                                onCheckedChanged: {
                                    if (checked) {
                                        radioButton.checked = false
                                        d.addToSelectedChannels(model)
                                    } else {
                                        d.removeFromSelectedChannels(model)
                                    }

                                    Qt.callLater(() => checkedCount += checked ? 1 : -1)
                                }

                                Connections {
                                    target: d

                                    function onSetSelectedChannels(channels) {
                                        communitySubItem.checked = channels.includes(
                                                    model.itemId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        StatusButton {
            Layout.fillWidth: true
            text: root.acceptMode === InDropdown.AcceptMode.Add
                  ? qsTr("Add") : qsTr("Update")

            onClicked: {
                if (radioButton.checked) {
                    root.communitySelected()
                    return
                }

                root.channelsSelected(Array.from(d.selectedChannels.values()))
            }
        }
    }
}
