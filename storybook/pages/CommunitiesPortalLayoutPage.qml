import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Popups.Dialog 0.1

import AppLayouts.CommunitiesPortal 1.0
import AppLayouts.CommunitiesPortal.stores 1.0

import SortFilterProxyModel 0.2

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ColumnLayout {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            CommunitiesPortalLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                communitiesStore: CommunitiesStore {
                    readonly property string locale: ""
                    readonly property int unreadNotificationsCount: 42
                    readonly property string communityTags:
                        JSON.stringify({"Activism":"✊","Art":"🎨","Blockchain":"🔗","Books & blogs":"📚","Career":"💼"})
                    readonly property var curatedCommunitiesModel: SortFilterProxyModel {

                        sourceModel: CommunitiesPortalDummyModel { id: mockedModel }

                        filters: IndexFilter {
                            inverted: true
                            minimumIndex: Math.floor(slider.value)
                        }
                    }

                    function setActiveCommunity() {
                        logs.logEvent("CommunitiesStore::setActiveCommunity", ["communityId"], arguments)
                    }
                }

                // TODO: onCompleted handler and localAccountSensitiveSettings are here to allow opening
                // "Import Community" and "Create New Community" popups. However those popups shouldn't
                // be tightly coupled with `CommunitiesPortalLayout` so it should be refactored in the next step.
                // Pressing buttons "Import using key" and "Create new community" should only request for opening
                // dialogs, and in Storybook it should be logged in the same way as calls to stores.
                // Mentioned popups should have their own pages in the Storybook.
                Component.onCompleted: {
                    Global.appMain = this
                }

                QtObject {
                    id: localAccountSensitiveSettings
                    readonly property bool isDiscordImportToolEnabled: false
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            Row {
                Text {
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

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        CommunitiesPortalModelEditor {
            anchors.fill: parent
            model: mockedModel
        }
    }
}
