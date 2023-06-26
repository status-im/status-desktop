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

    property bool allowChoosingEntireCommunity: false
    property bool showAddChannelButton: false

    property string communityName
    property string communityImage
    property string communityColor

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

        readonly property int defaultVMargin: 9
        readonly property int maxHeightCountNo: 5
        readonly property int itemStandardHeight: 44
        readonly property var selectedChannels: new Set()

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
            selectedChannels.add(model.itemId)
            selectedChannelsChanged()
        }

        function removeFromSelectedChannels(model) {
            selectedChannels.delete(model.itemId)
            selectedChannelsChanged()
        }
    }

   contentItem: ColumnLayout {
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
            Layout.topMargin: d.defaultVMargin
            Layout.preferredHeight: d.itemStandardHeight

            visible: root.allowChoosingEntireCommunity
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

            visible: root.allowChoosingEntireCommunity
        }
        StatusScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.minimumHeight: Math.min(d.maxHeightCountNo * d.itemStandardHeight, contentHeight)
            Layout.maximumHeight: Layout.minimumHeight
            contentWidth: availableWidth
            Layout.bottomMargin: d.defaultVMargin
            Layout.topMargin:
                !root.allowChoosingEntireCommunity && !root.allowChoosingEntireCommunity ? d.defaultVMargin : 0

            padding: 0

            ColumnLayout {
                id: scrollableColumn
                width: scrollView.availableWidth
                spacing: 0

                StatusIconTextButton {
                    Layout.preferredHeight: 36
                    visible: root.showAddChannelButton
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

                        filters: AnyOf {
                            ValueFilter {
                                roleName: "categoryId"
                                value: ""
                            }
                            ValueFilter {
                                roleName: "isCategory"
                                value: true
                            }
                        }

                        sorters: [
                            RoleSorter {
                                roleName: "categoryPosition"
                                priority: 2 // Higher number === higher priority
                            },
                            RoleSorter {
                                roleName: "position"
                                priority: 1
                            }
                        ]
                    }

                    ColumnLayout {
                        id: column

                        readonly property var topModel: model
                        readonly property alias checkBox: loader.item
                        property int checkedCount: 0

                        readonly property bool isCategory: model.isCategory
                        readonly property string categoryId: model.categoryId

                        Layout.fillWidth: true
                        spacing: 0

                        visible: {
                            if (!isCategory)
                                return d.search(model.name, searcher.text)

                            const subItemsCount = subItemsRepeater.count

                            for (let i = 0; i < subItemsCount; i++)
                                if (subItemsRepeater.itemAt(i).show)
                                    return true

                            return false
                        }

                        Loader {
                            id: loader

                            Layout.fillWidth: true
                            Layout.preferredHeight: d.itemStandardHeight
                            Layout.topMargin: isCategory ? d.defaultVMargin : 0
                            sourceComponent: isCategory
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

                                    asset.name: model.icon ?? ""
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

                                CategoryListItem {
                                    title: model.name

                                    checkState: {
                                        if (checkedCount === subItems.count)
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

                        SortFilterProxyModel {
                            id: subItems

                            sourceModel: isCategory ? root.model : null

                            filters: AllOf {
                                ValueFilter {
                                    roleName: "categoryId"
                                    value: column.categoryId
                                }
                                ValueFilter {
                                    roleName: "isCategory"
                                    value: false
                                }
                            }

                            sorters: RoleSorter {
                                roleName: "position"
                            }
                        }

                        Repeater {
                            id: subItemsRepeater

                            model: subItems

                            function setAll(checkState) {
                                const subItemsCount = count

                                for (let i = 0; i < subItemsCount; i++) {
                                    itemAt(i).checkState = checkState
                                }
                            }

                            CommunityListItem {
                                id: communitySubItem

                                readonly property bool show:
                                    d.search(model.name, searcher.text)

                                Layout.fillWidth: true

                                visible: show

                                title: "#" + model.name

                                asset.name: model.icon ?? ""
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

                StatusBaseText {
                    id: noContactsText

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    visible: {
                        for (let i = 0; i < topRepeater.count; i++) {
                            const item = topRepeater.itemAt(i)
                            if (item && item.visible)
                                return false
                        }

                        return true
                    }

                    text: qsTr("No channels found")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.tertiaryTextFontSize
                    elide: Text.ElideRight
                    lineHeight: 1.2
                }
            }
        }

        StatusButton {
            Layout.fillWidth: true

            enabled: root.acceptMode === InDropdown.AcceptMode.Update
                     || d.selectedChannels.size > 0

            text: {
                if (root.acceptMode === InDropdown.AcceptMode.Update)
                    return qsTr("Update")

                if (radioButton.checked)
                    return qsTr("Add community")

                if (d.selectedChannels.size === 0)
                    return qsTr("Add")

                return qsTr("Add %n channel(s)", "", d.selectedChannels.size)
            }


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
