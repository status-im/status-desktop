import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0
import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.controls.community 1.0

Flickable {
    id: root

    property var model

    property var assetKeys: []
    property var collectibleKeys: []

    QtObject {
        id: d

        property int newType
        property string newKey
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

                            CommunityPermissionsHoldingItemEditor {
                                Layout.fillWidth: true
                                panelText: "Who holds [item " + model.index + "]"
                                type: model.type
                                key: model.key
                                amountText: model.amount

                                assetKeys: root.assetKeys
                                collectibleKeys: root.collectibleKeys

                                onTypeChanged: model.type = type
                                onKeyChanged: model.key = key
                                onAmountTextChanged: model.amount = parseFloat(amountText)
                            }
                        }
                    }

                    CommunityPermissionsHoldingItemEditor {
                        panelText: "New holding item"
                        type: d.newType
                        key: d.newKey
                        amountText: d.newAmount

                        assetKeys: root.assetKeys
                        collectibleKeys: root.collectibleKeys

                        onTypeChanged: d.newType = type
                        onKeyChanged: d.newKey = key
                        onAmountTextChanged: d.newAmount = parseFloat(amountText)
                    }

                    Button {
                        enabled: d.newKey && (d.newAmount || d.newType === HoldingTypes.Type.Ens)
                        Layout.fillWidth: true
                        text: "Add new holding"

                        onClicked: {
                            model.holdingsListModel.append({
                                type: d.newType,
                                key: d.newKey,
                                amount: d.newAmount
                            })
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
