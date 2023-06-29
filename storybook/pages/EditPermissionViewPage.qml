import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.views 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        EditPermissionView {
            id: editPermissionView

            anchors.fill: parent

            isEditState: isEditStateCheckBox.checked
            isPrivate: isPrivateCheckBox.checked
            permissionDuplicated: isPermissionDuplicatedCheckBox.checked
            permissionTypeLimitReached: isLimitReachedCheckBox.checked

            assetsModel: AssetsModel {}
            collectiblesModel: CollectiblesModel {}
            channelsModel: ChannelsModel {}

            communityDetails: QtObject {
                readonly property string id: "sox"
                readonly property string name: "Socks"
                readonly property string image: ModelsData.icons.socks
                readonly property string color: "red"
                readonly property bool owner: isOwnerCheckBox.checked
            }

            onCreatePermissionClicked: {
                logs.logEvent("EditPermissionView::onCreatePermissionClicked")
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
                    id: isPermissionDuplicatedCheckBox

                    text: "Is permission duplicated"
                }

                CheckBox {
                    id: isLimitReachedCheckBox

                    text: "Is limit reached"
                }
            }

            Button {
                text: "Reset changes"

                onClicked: editPermissionView.resetChanges()
            }

            Label {
                text: "Is dirty: " + editPermissionView.dirty
            }
        }
    }
}
