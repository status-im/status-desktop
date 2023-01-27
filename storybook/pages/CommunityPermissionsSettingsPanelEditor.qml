import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0
import StatusQ.Core.Utils 0.1

Flickable {
    id: root

    property var model

    QtObject {
        id: d
        property string newName
        property double newAmount
        property string newImageSource
        property string newChannelName
        property string newChannelIconSource
    }

    contentWidth: root.width
    contentHeight: globalContent.implicitHeight

    ColumnLayout {
        id: globalContent
        spacing: 10
        anchors.fill: parent

        Repeater {
            model: root.model

            Rectangle {
                radius: 16
                color: "whitesmoke"
                Layout.preferredHeight: content.implicitHeight + 50
                Layout.fillWidth: true

                ColumnLayout {
                    id: content
                    spacing: 25
                    anchors.fill: parent
                    anchors.margins: 20

                    Label {
                        Layout.fillWidth: true
                        text: "Permission " + (model.index)
                        font.weight: Font.Bold
                        font.pixelSize: 17
                    }

                    ColumnLayout {
                        Repeater {
                            model: holdingsListModel

                            CommunityPermissionsSettingItemEditor {
                                Layout.fillWidth: true
                                panelText: "Who holds [item " + model.index + "]"
                                name: model.name
                                icon: model.imageSource
                                amountText: model.amount
                                isAmountVisible: true
                                iconsModel: AssetsCollectiblesIconsModel {}
                                onNameChanged: model.name = name
                                onIconChanged: model.imageSource = icon
                                onAmountTextChanged: model.amount = parseFloat(amountText)
                            }
                        }
                    }

                    CommunityPermissionsSettingItemEditor {
                        panelText: "New holdings item"
                        name: d.newName
                        icon: d.newImageSource
                        amountText: d.newAmount
                        isAmountVisible: true
                        iconsModel: AssetsCollectiblesIconsModel {}
                        onNameChanged: d.newName = name
                        onIconChanged: d.newImageSource = icon
                        onAmountTextChanged: d.newAmount = parseFloat(amountText)
                    }

                    Button {
                        enabled: d.newName && d.newAmount && d.newImageSource
                        Layout.fillWidth: true
                        text: "Add new holding"
                        onClicked: {
                            model.holdingsListModel.append([{
                                                                type: 1,
                                                                key: d.newName,
                                                                name: d.newName,
                                                                amount: d.newAmount,
                                                                imageSource: d.newImageSource
                                                         }])
                        }
                    }

                    ColumnLayout {
                        Repeater {
                             model: channelsListModel
                             CommunityPermissionsSettingItemEditor {
                                 isEmojiSelectorVisible: true

                                 panelText: "In [item " + model.index + "]"
                                 name: model.text
                                 icon: model.iconSource ? model.iconSource : ""
                                 emoji: model.emoji ? model.emoji : ""
                                 iconsModel: AssetsCollectiblesIconsModel {}
                                 onNameChanged: model.name = name
                                 onIconChanged: model.iconSource = icon
                                 onEmojiChanged: model.emoji = emoji
                             }
                        }
                    }


                    CommunityPermissionsSettingItemEditor {
                        Layout.fillWidth: true
                        panelText: "New In item"
                        name: d.newChannelName
                        icon: d.newChannelIconSource
                        iconsModel: AssetsCollectiblesIconsModel {}
                        onNameChanged: d.newChannelName = name
                        onIconChanged: d.newChannelIconSource = icon
                    }

                    Button {
                        enabled: d.newChannelIconSource && d.newChannelName
                        Layout.fillWidth: true
                        text: "Add new channel"
                        onClicked: {
                            model.channelsListModel.append([{
                                                                key: d.newChannelName,
                                                                name: d.newChannelName,
                                                                iconSource: d.newChannelIconSource
                                                         }])
                        }
                    }

                    CheckBox {
                        text: "Permission is private"
                        checked: model.isPrivate
                        onToggled: model.isPrivate = checked
                    }
                }
            }
        }
    }
}
