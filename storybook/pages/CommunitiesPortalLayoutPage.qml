import QtQuick 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Popups.Dialog 0.1

import AppLayouts.CommunitiesPortal 1.0
import AppLayouts.CommunitiesPortal.stores 1.0

import SortFilterProxyModel 0.2

SplitView {
    anchors.fill: parent

    ColumnLayout {
        SplitView.fillWidth: true

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
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
        }

        Pane {
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
