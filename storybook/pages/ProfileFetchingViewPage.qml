import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Onboarding.views 1.0
import AppLayouts.Onboarding.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ProfileFetchingView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            startupStore: StartupStore {
                id: startupStore

                property QtObject currentStartupState: QtObject {
                    property string stateType
                }

                property ListModel fetchingDataModel: ListModel {
                    Component.onCompleted: append([
                        {
                        entity: Constants.onboarding.profileFetching.entity.profile,
                        loadedMessages: 0,
                        totalMessages: 0,
                        icon: "profile"
                    },
                    {
                        entity: Constants.onboarding.profileFetching.entity.contacts,
                        loadedMessages: 0,
                        totalMessages: 0,
                        icon: "contact-book"
                    },
                    {
                        entity: Constants.onboarding.profileFetching.entity.communities,
                        loadedMessages: 0,
                        totalMessages: 0,
                        icon: "communities"
                    },
                    {
                        entity: Constants.onboarding.profileFetching.entity.settings,
                        loadedMessages: 0,
                        totalMessages: 0,
                        icon: "settings"
                    }])
                }

                function doPrimaryAction() {
                    logs.logEvent("StartupStore::doPrimaryAction")
                }

                function doSecondaryAction() {
                    logs.logEvent("StartupStore::doSecondaryAction")
                }

                function doTertiaryAction() {
                    logs.logEvent("StartupStore::doTertiaryAction")
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ProfileFetchingModelEditor {
            anchors.fill: parent
            model: startupStore.fetchingDataModel

            onStateChanged: {
                if (state === Constants.startupState.profileFetching) {
                    for(let i = 0; i < startupStore.fetchingDataModel.rowCount(); i++) {
                        startupStore.fetchingDataModel.setProperty(i, "totalMessages", 0)
                        startupStore.fetchingDataModel.setProperty(i, "loadedMessages", 0)
                    }
                }
                else if (state === Constants.startupState.profileFetchingSuccess) {
                    for(let i = 0; i < startupStore.fetchingDataModel.rowCount(); i++) {
                        let n = Math.ceil(Math.random() * 10) + 1
                        startupStore.fetchingDataModel.setProperty(i, "totalMessages", n)
                        startupStore.fetchingDataModel.setProperty(i, "loadedMessages", n)
                    }
                }
                else if (state === Constants.startupState.profileFetchingTimeout) {
                    for(let i = 0; i < startupStore.fetchingDataModel.rowCount(); i++) {
                        let n = Math.ceil(Math.random() * 5)
                        startupStore.fetchingDataModel.setProperty(i, "totalMessages", n + 5)
                        startupStore.fetchingDataModel.setProperty(i, "loadedMessages", n)
                    }
                }

                startupStore.currentStartupState.stateType = state
            }
        }
    }
}

// category: Views
