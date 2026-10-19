import QtQuick
import QtQml
import QtQuick.Controls

import QtQml.Models

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import SortFilterProxyModel

StatusMenu {
    id: root

    property var locationModel
    property string personalChatsSectionId
    readonly property int numDefaultItems: 2
    property bool threadsEnabled: false
    property var threadLocationModel
    property bool threadLocationsLoading: false
    property bool threadLocationsError: false
    property string threadLocationChatId

    signal threadLocationsRequested(string chatId)
    signal threadLocationSectionRequested(string sectionId)

    signal itemClicked(string firstLevelItemValue, string secondLevelItemValue, string threadId)

    signal resetSearchSelection()

    signal setSearchSelection(string text,
                              string secondaryText,
                              string imageSource,
                              bool isIdenticon,
                              string iconName,
                              string iconColor,
                              bool isUserIcon,
                              int colorId,
                              string threadText)

    StatusAction {
        text: qsTr("Anywhere")
        onTriggered: {
            root.resetSearchSelection();
            root.itemClicked("", "", "");
        }
    }

    StatusMenuSeparator { }

    StatusMenuInstantiator {
        model: root.locationModel
        menu: root
        indexOffset: root.numDefaultItems

        delegate: DelegateChooser {
            role: "hasSubItems"

            DelegateChoice {
                roleValue: false
                delegate: StatusSearchPopupMenuItem {
                    text: model.title
                    assetSettings.name: !!model.imageSource ? !!model.imageSource : model.iconName
                    assetSettings.isImage: !!model.imageSource
                    assetSettings.isLetterIdenticon: !model.imageSource && !model.iconName
                    assetSettings.imgIsIdenticon: false
                    onTriggered: {
                        root.resetSearchSelection()
                        root.setSearchSelection(text,
                                                "",
                                                "",
                                                assetSettings.imgIsIdenticon,
                                                assetSettings.name,
                                                assetSettings.color,
                                                model.isUserIcon,
                                                model.colorId, "")
                        root.itemClicked(model.value, "", "")
                    }
                }
            }

            DelegateChoice {
                roleValue: true
                delegate: StatusMenu {
                    id: subMenuDelegate

                    readonly property var subItemsModel: model.subItems
                    readonly property string parentValue: model.value
                    readonly property string parentIconName: model.iconName
                    readonly property string parentImageSource: model.imageSource
                    readonly property string parentIdenticonColor: !!model.iconColor ? model.iconColor : defaultIconColor
                    readonly property bool parentIsIdenticon: false

                    title: model.title
                    assetSettings.name: !!model.iconName ? model.iconName : model.imageSource
                    assetSettings.color: !!model.iconColor ? model.iconColor : defaultIconColor
                    assetSettings.isImage: !!model.imageSource
                    assetSettings.imgIsIdenticon: false
                    assetSettings.isLetterIdenticon: !model.imageSource && !model.iconName

                    onAboutToShow: {
                        if (root.threadsEnabled)
                            root.threadLocationSectionRequested(parentValue)
                    }

                    StatusMenuInstantiator {
                        id: menuLoader

                        readonly property string parentValue: subMenuDelegate.parentValue
                        readonly property bool belongsToPersonalChatsSection:
                            parentValue === root.personalChatsSectionId
                        readonly property string parentTitleText: subMenuDelegate.title
                        readonly property string parentIconName: subMenuDelegate.parentIconName
                        readonly property string parentImageSource: subMenuDelegate.parentImageSource
                        readonly property string parentIdenticonColor: subMenuDelegate.parentIdenticonColor
                        readonly property bool parentIsIdenticon: subMenuDelegate.parentIsIdenticon

                        menu: subMenuDelegate
                        model: SortFilterProxyModel {
                            sourceModel: subMenuDelegate.subItemsModel
                            sorters: [
                                RoleSorter {
                                    roleName: "position"
                                    sortOrder: Qt.AscendingOrder
                                },
                                RoleSorter {
                                    roleName: "lastMessageTimestamp"
                                    sortOrder: Qt.DescendingOrder
                                }
                            ]
                        }

                        function selectChat(chat, threadId = "", threadName = "") {
                            root.resetSearchSelection()
                            if (menuLoader.belongsToPersonalChatsSection) {
                                root.setSearchSelection(chat.text, "", chat.imageSource, false,
                                                        chat.iconName, chat.iconColor,
                                                        chat.isUserIcon, chat.colorId, threadName)
                            } else {
                                root.setSearchSelection(menuLoader.parentTitleText, chat.text,
                                                        menuLoader.parentImageSource,
                                                        menuLoader.parentIsIdenticon,
                                                        menuLoader.parentIconName,
                                                        menuLoader.parentIdenticonColor,
                                                        false, -1, threadName)
                            }
                            root.itemClicked(menuLoader.parentValue, chat.value, threadId)
                            root.dismiss()
                        }

                        delegate: DelegateChooser {
                            role: "hasThreads"
                            DelegateChoice {
                                roleValue: true
                                delegate: root.threadsEnabled ? threadChannelComponent : channelComponent
                            }
                            DelegateChoice {
                                delegate: channelComponent
                            }
                        }
                    }

                    Component {
                        id: channelComponent
                        StatusSearchPopupMenuItem {
                            required property var model
                            text: model.text
                            assetSettings.name: model.isImage ? model.imageSource : ""
                            assetSettings.emoji: !model.isUserIcon ? model.imageSource : ""
                            assetSettings.color: model.isUserIcon ? Theme.palette.userCustomizationColors[model.colorId] : model.iconColor
                            assetSettings.bgColor: model.iconColor
                            assetSettings.charactersLen: model.isUserIcon ? 2 : 1
                            onTriggered: menuLoader.selectChat(model)
                        }
                    }

                    Component {
                        id: threadChannelComponent
                        StatusMenu {
                            id: channelMenu
                            required property var model
                            title: model.text
                            assetSettings.name: model.isImage ? model.imageSource : ""
                            assetSettings.isImage: model.isImage
                            assetSettings.emoji: !model.isUserIcon ? model.imageSource : ""
                            assetSettings.color: model.isUserIcon ? Theme.palette.userCustomizationColors[model.colorId] : model.iconColor
                            assetSettings.bgColor: model.iconColor
                            assetSettings.charactersLen: model.isUserIcon ? 2 : 1

                            onAboutToShow: {
                                root.threadLocationChatId = model.value
                                root.threadLocationsRequested(model.value)
                            }

                            StatusMenuItem {
                                objectName: "searchInParentChat"
                                text: channelMenu.title
                                Accessible.name: channelMenu.title
                                contentItem: Item {
                                    implicitWidth: 180
                                    implicitHeight: headerLabels.implicitHeight
                                    Column {
                                        id: headerLabels
                                        width: parent.width
                                        spacing: 4
                                        StatusBaseText {
                                            width: parent.width
                                            text: qsTr("Search in")
                                            color: Theme.palette.baseColor1
                                        }
                                        StatusBaseText {
                                            width: parent.width
                                            text: (menuLoader.belongsToPersonalChatsSection ? "" : "#") + channelMenu.title
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                                onTriggered: menuLoader.selectChat(channelMenu.model)
                            }
                            StatusMenuSeparator {}
                            StatusMenuItem {
                                visible: root.threadLocationsLoading || root.threadLocationsError || threadItems.count === 0
                                height: visible ? implicitHeight : 0
                                enabled: root.threadLocationsError
                                text: root.threadLocationsLoading ? qsTr("Loading threads…") :
                                      root.threadLocationsError ? qsTr("Couldn't load threads. Retry") : qsTr("No threads")
                                onTriggered: root.threadLocationsRequested(channelMenu.model.value)
                            }
                            StatusMenuInstantiator {
                                id: threadItems
                                menu: channelMenu
                                indexOffset: 3
                                model: channelMenu.visible && root.threadLocationChatId === channelMenu.model.value
                                       ? root.threadLocationModel : null
                                delegate: StatusSearchPopupMenuItem {
                                    required property var model
                                    text: model.text
                                    assetSettings.name: "thread"
                                    assetSettings.isImage: false
                                    assetSettings.isLetterIdenticon: false
                                    onTriggered: menuLoader.selectChat(channelMenu.model, model.value, model.text)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
