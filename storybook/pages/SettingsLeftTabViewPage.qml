import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import Models 1.0
import Storybook 1.0

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.helpers 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    SettingsLeftTabView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        model: SettingsEntriesModel {
            isKeycardEnabled: ctrlIsKeycardEnabled.checked
            showWalletEntries: ctrlShowWalletEntries.checked
            showBackUpSeed: ctrlShowBackUpSeed.checked
            syncingBadgeCount: ctrlSyncingBadgeCount.value
            messagingBadgeCount: ctrlMessagingBadgeCount.value
        }
        onMenuItemClicked: (event) => logs.logEvent("onMenuItemClicked", ["event"], arguments)
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100
        SplitView.fillWidth: true

        logsView.logText: logs.logText

        RowLayout {
            spacing: 20
            Layout.fillHeight: true

            RowLayout {
                Label { text: "Syncing badge count:" }
                SpinBox {
                    id: ctrlSyncingBadgeCount
                    value: 1
                    from: 0
                    to: 999
                }
            }
            RowLayout {
                Label { text: "Messaging badge count:" }
                SpinBox {
                    id: ctrlMessagingBadgeCount
                    value: 2
                    from: 0
                    to: 999
                }
            }
            Switch {
                id: ctrlShowBackUpSeed
                checked: true
                text: "Show backup seed"
            }
            Switch {
                id: ctrlShowWalletEntries
                checked: true
                text: "Show wallet entries"
            }
            Switch {
                id: ctrlIsKeycardEnabled
                checked: true
                text: "Is keycard enabled"
            }
        }
    }
}

// category: Views
// status: good
