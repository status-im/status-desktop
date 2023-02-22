import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0
import Models 1.0


SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        CommunityPermissionsSettingsPanel {
            id: communityPermissionsSettingsPanel

            anchors {
                fill: parent
                topMargin: 50
            }
            store: CommunitiesStore {
                readonly property bool isOwner: isOwnerCheckBox.checked

                property var permissionConflict: QtObject { // Backend conflicts object model assignment. Now mocked data.
                    property bool exists: false
                    property string holdings: qsTr("1 ETH")
                    property string permissions: qsTr("View and Post")
                    property string channels: qsTr("#general")

                }

                readonly property var permissionsModel: ListModel {}
                readonly property var assetsModel: AssetsModel {}
                readonly property var collectiblesModel: CollectiblesModel {}
                readonly property var channelsModel: ListModel {
                    Component.onCompleted: {
                        append([
                            {
                                key: "welcome",
                                iconSource: ModelsData.assets.inch,
                                name: "#welcome"
                            },
                            {
                                key: "general",
                                iconSource: ModelsData.assets.inch,
                                name: "#general"
                            }
                        ])
                    }
                }

                readonly property QtObject _d: QtObject {
                    id: d

                    property int keyCounter: 0

                    function createPermissionEntry(holdings, permissionType, isPrivate, channels) {
                        const permission = {
                            holdingsListModel: holdings,
                            channelsListModel: channels,
                            permissionType,
                            isPrivate
                        }

                        return permission
                    }
                }

                function createPermission(holdings, permissionType, isPrivate, channels, index = null) {
                    const permissionEntry = d.createPermissionEntry(
                                              holdings, permissionType, isPrivate, channels)

                    permissionEntry.key = "" + d.keyCounter++
                    permissionsModel.append(permissionEntry)
                }

                function editPermission(key, holdings, permissionType, channels, isPrivate) {
                    const permissionEntry = d.createPermissionEntry(
                                              holdings, permissionType, isPrivate, channels)

                    const index = ModelUtils.indexOf(permissionsModel, "key", key)
                    permissionsModel.set(index, permissionEntry)
                }

                function removePermission(key) {
                    const index = ModelUtils.indexOf(permissionsModel, "key", key)
                    permissionsModel.remove(index)
                }
            }

            rootStore: QtObject {
                readonly property QtObject chatCommunitySectionModule: QtObject {
                    readonly property var model: ChannelsModel {}
                }

                readonly property QtObject mainModuleInst: QtObject {
                    readonly property QtObject activeSection: QtObject {
                        readonly property string name: "Socks"
                        readonly property string image: ModelsData.icons.socks
                        readonly property string color: "red"
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: isOwnerCheckBox

                text: "Is owner"
            }

            Label {
                text: "Is dirty: " + communityPermissionsSettingsPanel.dirty
            }
        }
    }
}
