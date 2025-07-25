import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Core.Utils

import AppLayouts.Communities.views

import Models
import Storybook


SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

            PermissionsView {
                anchors {
                    fill: parent
                    margins: 50
                }

                ListModel {
                    id: permissionsModel

                    Component.onCompleted: append(PermissionsModel.permissionsModelData)
                }

                ListModel {
                    id: emptyModel
                }

                permissionsModel: emptyModelCheckBox.checked ? emptyModel : permissionsModel

                assetsModel: AssetsModel {
                    id: assetsModel
                }

                collectiblesModel: CollectiblesModel {
                    id: collectiblesModel
                }

                channelsModel: ChannelsModel {
                    id: channelsModel
                }

                communityDetails: QtObject {
                    readonly property string id: "sox"
                    readonly property string name: "Socks"
                    readonly property string image: ModelsData.icons.socks
                    readonly property string color: "red"
                    readonly property bool owner: isOwnerCheckBox.checked
                    readonly property bool admin: isAdminCheckBox.checked
                }

                function log(method, index) {
                    logs.logEvent(`PermissionsView::${method} - index: ${index}`)
                }

                onEditPermissionRequested: log("editPermissionRequested", index)
                onRemovePermissionRequested: log("removePermissionRequested", index)
                onDuplicatePermissionRequested: log("duplicatePermissionRequested", index)
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            CheckBox {
                id: isOwnerCheckBox

                text: "Is owner"
            }

            CheckBox {
                id: isAdminCheckBox

                text: "Is admin"
            }

            CheckBox {
                id: emptyModelCheckBox

                text: "Empty model"
            }

            Item {
                visible: emptyModelCheckBox.checked

                Layout.fillHeight: true
            }

            CommunityPermissionsSettingsPanelEditor {
                clip: true
                visible: !emptyModelCheckBox.checked

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: permissionsModel

                assetKeys: assetsModel.data.map(asset => asset.key)
                collectibleKeys: collectiblesModel.data.map(collectible => collectible.key)
                channelKeys: {
                    const array = ModelUtils.modelToArray(channelsModel,
                                                          ["itemId", "isCategory"])
                    const channelsOnly = array.filter(channel => !channel.isCategory)

                    return channelsOnly.map(channel => channel.itemId)
                }
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22813%3A497277&t=7gqqAFbdG5KrPOmn-0
