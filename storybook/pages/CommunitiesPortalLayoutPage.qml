import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Communities 1.0
import AppLayouts.Communities.stores 1.0

import SortFilterProxyModel 0.2

import Storybook 1.0
import Models 1.0

import utils 1.0
import mainui 1.0

SplitView {
    id: root
    Logs { id: logs }

    Popups {
        popupParent: root
        rootStore: QtObject {}
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        CommunitiesPortalLayout {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            assetsModel: AssetsModel {}
            collectiblesModel:  CollectiblesModel {}
            communitiesStore: CommunitiesStore {
                readonly property int unreadNotificationsCount: 42
                readonly property string communityTags: ModelsData.communityTags
                readonly property var curatedCommunitiesModel: SortFilterProxyModel {

                    sourceModel: CommunitiesPortalDummyModel { id: mockedModel }

                    filters: IndexFilter {
                        inverted: true
                        minimumIndex: Math.floor(slider.value)
                    }
                }

                function navigateToCommunity() {
                    logs.logEvent("CommunitiesStore::navigateToCommunity", ["communityId"], arguments)
                }
            }

            QtObject {
                id: localAccountSensitiveSettings
                readonly property bool isDiscordImportToolEnabled: false
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "number of communities:"
                }

                Slider {
                    id: slider
                    value: 9
                    from: 0
                    to: 9
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        CommunitiesPortalModelEditor {
            anchors.fill: parent
            model: mockedModel
        }
    }
}
