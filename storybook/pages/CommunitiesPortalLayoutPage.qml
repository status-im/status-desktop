import QtQuick 2.14
import QtQuick.Controls 2.14

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

        CommunitiesPortalLayout {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            communitiesStore: CommunitiesStore {
                readonly property string locale: ""
                readonly property int unreadNotificationsCount: 42
                readonly property string communityTags:
                    JSON.stringify({"Activism":"✊","Art":"🎨","Blockchain":"🔗","Books & blogs":"📚","Career":"💼","Collaboration":"🤝","Commerce":"🛒","Culture":"🎎","DAO":"🚀","DIY":"🔨","DeFi":"📈",
                                    "Design":"🧩","Education":"🎒","Entertainment":"🍿","Environment":"🌿","Ethereum":"Ξ","Event":"🗓","Fantasy":"🧙‍♂️","Fashion":"🧦","Food":"🌶","Gaming":"🎮","Global":"🌍",
                                    "Health":"🧠","Hobby":"📐","Innovation":"🧪","Language":"📜","Lifestyle":"✨","Local":"📍","Love":"❤️","Markets":"💎","Movies & TV":"🎞","Music":"🎶","NFT":"🖼","NSFW":"🍆",
                                    "News":"🗞","Non-profit":"🙏","Org":"🏢","Pets":"🐶","Play":"🎲","Podcast":"🎙️","Politics":"🗳️","Privacy":"👻","Product":"🍱","Psyche":"🍁","Security":"🔒","Social":"☕",
                                    "Software dev":"👩‍💻","Sports":"⚽️","Tech":"📱","Travel":"🗺","Vehicles":"🚕","Web3":"🌐"})
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
