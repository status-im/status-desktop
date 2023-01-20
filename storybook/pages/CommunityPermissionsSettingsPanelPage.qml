import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            CommunityPermissionsSettingsPanel {
                anchors {
                    fill: parent
                    topMargin: 50
                }
                store: CommunitiesStore {
                    readonly property bool isOwner: isOwnerCheckBox.checked

                    assetsModel: AssetsModel {}
                    collectiblesModel: CollectiblesModel {}
                    channelsModel: ListModel {
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

                    function editPermission(index, holdings, permissions, channels, isPrivate) {
                        logs.logEvent("CommunitiesStore::editPermission - index: " + index)
                    }

                    function duplicatePermission(index) {
                        logs.logEvent("CommunitiesStore::duplicatePermission - index: " + index)
                    }

                    function removePermission(index) {
                        logs.logEvent("CommunitiesStore::removePermission - index: " + index)
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
                            readonly property color color: "red"
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

            CheckBox {
                id: isOwnerCheckBox

                text: "Is owner"
            }
        }
    }
}
