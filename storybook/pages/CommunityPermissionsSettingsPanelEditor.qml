import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Utils 0.1

Flickable {
    id: root

    property var model

    property var assetKeys: []
    property var collectibleKeys: []
    property var channelKeys: []

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
        spacing: 20
        anchors.fill: parent

        Repeater {
            model: root.model

            GroupBox {
                title: `Permission ${model.index}`

                Layout.preferredHeight: content.implicitHeight + 50
                Layout.fillWidth: true

                ColumnLayout {
                    id: content
                    spacing: 20
                    anchors.fill: parent

                    Repeater {
                        model: holdingsListModel

                        GroupBox {
                            Layout.fillWidth: true
                            title: `Who holds [item ${model.index}]`

                            CommunityPermissionsHoldingItemEditor {
                                anchors.fill: parent

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

                    GroupBox {
                        Layout.fillWidth: true
                        title: "New holding item"

                        ColumnLayout {
                            anchors.fill: parent

                            CommunityPermissionsHoldingItemEditor {
                                Layout.fillWidth: true

                                type: d.newType
                                key: d.newKey
                                amountText: d.newAmount

                                assetKeys: root.assetKeys
                                collectibleKeys: root.collectibleKeys

                                onTypeChanged: d.newType = type
                                onKeyChanged: d.newKey = key
                                onAmountTextChanged: d.newAmount = parseFloat(amountText)
                            }

                            MenuSeparator {
                                Layout.fillWidth: true
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
                        }
                    }


                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Channels"
                    }

                    Flow {
                        Layout.fillWidth: true

                        Repeater {
                            id: channelsRepeater

                            model: root.channelKeys

                            CheckBox {
                                text: modelData

                                checked: ModelUtils.contains(
                                             channelsListModel, "key", modelData)

                                onToggled: {
                                    const channels = []
                                    const count = channelsRepeater.count

                                    for (let i = 0; i < count; i++) {
                                        const checked = channelsRepeater.itemAt(i).checked

                                        if (checked) {
                                            const key = root.channelKeys[i]
                                            channels.push({ key })
                                        }
                                    }

                                    channelsListModel.clear()
                                    channelsListModel.append(channels)
                                }
                            }
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
