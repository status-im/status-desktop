import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import Storybook 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    property var dialog

    function createAndOpenDialog() {
        dialog = dlgComponent.createObject(popupBg)
        dialog.open()
    }

    Component.onCompleted: createAndOpenDialog()

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: createAndOpenDialog()
            }
        }

        Component {
            id: dlgComponent
            CreateChannelPopup {
                id: dialog
                anchors.centerIn: parent
                modal: false
                closePolicy: Popup.NoAutoClose
                destroyOnClose: true

                isEdit: isEditCheckBox.checked
                isDeleteable: isDeleteableCheckBox.checked
                isDiscordImport: isDiscordCheckBox.checked

                Binding on channelName {
                    value: "test-channel"
                    when: dialog.isEdit
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Binding on channelDescription {
                    value: "TEST TEST TEST"
                    when: dialog.isEdit
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Binding on channelColor {
                    value: "pink"
                    when: dialog.isEdit
                    restoreMode: Binding.RestoreBindingOrValue
                }

                communitiesStore: QtObject {
                    property string discordImportChannelName
                    readonly property bool discordImportInProgress: false
                    readonly property bool discordDataExtractionInProgress: false
                    readonly property int discordImportErrorsCount: 0
                    readonly property int discordImportWarningsCount: 0
                    readonly property int discordOldestMessageTimestamp: 0

                    property var discordFileList: ListModel {
                        readonly property int selectedCount: count
                        property bool selectedFilesValid
                    }

                    property var discordCategoriesModel: ListModel {}

                    property var discordChannelsModel: ListModel {
                        property bool hasSelectedItems
                        readonly property int count: 32 // hide the parsing/loading spinner
                    }

                    function setFileListItems(filePaths) {
                        for (const filePath of filePaths) {
                            discordFileList.append({"filePath": filePath, errorMessage: ""})
                        }
                    }

                    function removeFileListItem(path) {
                        for (let i = 0; i < discordFileList.count; i++) {
                            const item = discordFileList.get(i)
                            if (item.filePath === path)
                                discordFileList.remove(i)
                        }
                    }

                    function clearFileList() {
                        discordFileList.clear()
                        discordFileList.selectedFilesValid = false
                    }

                    function clearDiscordCategoriesAndChannels() {
                        discordCategoriesModel.clear()
                        discordChannelsModel.clear()
                        discordChannelsModel.hasSelectedItems = false
                    }

                    function requestExtractChannelsAndCategories() {
                        discordFileList.selectedFilesValid = true
                    }

                    function toggleOneDiscordChannel(id) {
                        logs.logEvent("toggleOneDiscordChannel", ["id"], arguments)
                    }

                    function resetDiscordImport() {
                        logs.logEvent("resetDiscordImport")
                    }

                    function requestCancelDiscordChannelImport(id) {
                        logs.logEvent("requestCancelDiscordChannelImport", ["id"], arguments)
                    }

                    function requestImportDiscordChannel(args, timestamp) {
                        logs.logEvent("requestImportDiscordChannel", ["args", "timestamp"], arguments)
                    }
                }

                emojiPopup: Popup {
                    id: inner_emojiPopup

                    parent: root

                    property var emojiSize

                    Button {
                        text: "😃"
                        onClicked: {
                            emojiPopup.emojiSelected(text, false)
                            emojiPopup.close()
                        }
                    }

                    signal emojiSelected(string emoji, bool atCu)
                }


                onCreateCommunityChannel: function(chName, chDescription, chEmoji, chColor, chCategoryId) {
                    logs.logEvent("onCreateCommunityChannel",
                                  ["chName", "chDescription", "chEmoji", "chColor", "chCategoryId"], arguments)
                }

                onEditCommunityChannel: function(chName, chDescription, chEmoji, chColor, chCategoryId) {
                    logs.logEvent("onEditCommunityChannel",
                                  ["chName", "chDescription", "chEmoji", "chColor", "chCategoryId"], arguments)
                }

                onDeleteCommunityChannel: () => {
                                              logs.logEvent("onDeleteCommunityChannel")
                                          }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        RowLayout {
            CheckBox {
                id: isEditCheckBox
                text: "isEdit"
                onToggled: if (checked) isDiscordCheckBox.checked = false
            }
            CheckBox {
                id: isDeleteableCheckBox
                enabled: isEditCheckBox.checked
                text: "isDeleteable"
            }
            CheckBox {
                id: isDiscordCheckBox
                enabled: !isEditCheckBox.checked
                text: "isDiscordImport"
                onToggled: {
                    if (!!dialog && dialog.opened)
                        dialog.close()
                }
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2975%3A488608
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2975%3A488256
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2903%3A348301
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2975%3A488848
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2975%3A489237
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2975%3A489607
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2975%3A492910
