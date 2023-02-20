import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Pane {
        id: root

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        CommunityNewPermissionView {
            id: communityNewPermissionView

            anchors.fill: parent

            isEditState: isEditStateCheckBox.checked
            isPrivate: isPrivateCheckBox.checked
            duplicationWarningVisible: isDuplicationWarningVisibleCheckBox.checked

            store: CommunitiesStore {
                readonly property var assetsModel: AssetsModel {}
                readonly property var collectiblesModel: CollectiblesModel {}
                readonly property var channelsModel: ChannelsModel {}
                readonly property var permissionConflict: QtObject {
                    property bool exists: true
                    property string holdings: "1 ETH"
                    property string permissions: "View and Post"
                    property string channels: "#general"

                }

                readonly property bool isOwner: isOwnerCheckBox.checked

                function createPermission(holdings, permissions, isPrivate, channels) {
                    logs.logEvent("CommunitiesStore::creatPermission")
                }

                function editPermission(key, holdings, permissions, channels, isPrivate) {
                    logs.logEvent("CommunitiesStore::editPermission - key: " + key)
                }

                function removePermission(key) {
                    logs.logEvent("CommunitiesStore::removePermission - key: " + key)
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
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText


        ColumnLayout {

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: isOwnerCheckBox

                    text: "Is owner"
                }

                CheckBox {
                    id: isEditStateCheckBox

                    text: "Is edit state"
                }

                CheckBox {
                    id: isPrivateCheckBox

                    text: "Is private"
                }

                CheckBox {
                    id: isDuplicationWarningVisibleCheckBox

                    text: "Is duplication warning visible"
                }
            }

            Button {
                text: "Reset changes"

                onClicked: communityNewPermissionView.resetChanges()
            }

            Label {
                text: "Is dirty: " + communityNewPermissionView.dirty
            }
        }
    }
}
