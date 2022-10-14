import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1

import utils 1.0
import shared.popups.keycard 1.0

import "../stores"
import "./keycard"

SettingsContentBase {
    id: root

    property ProfileSectionStore profileSectionStore
    property KeycardStore keycardStore
    property string mainSectionTitle: ""

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Get Keycard")
        onClicked: {
            Global.openLink(Constants.keycard.general.purchasePage)
        }
    }

    function handleBackAction() {
        if (stackLayout.currentIndex === d.detailsViewIndex) {
            root.profileSectionStore.backButtonName = ""
            root.sectionTitle = root.mainSectionTitle
            stackLayout.currentIndex = d.mainViewIndex
        }
    }

    StackLayout {
        id: stackLayout

        currentIndex: d.mainViewIndex

        QtObject {
            id: d
            readonly property int mainViewIndex: 0
            readonly property int detailsViewIndex: 1

            property string observedKeycardUid: ""
        }

        MainView {
            Layout.preferredWidth: root.contentWidth
            keycardStore: root.keycardStore

            onDisplayKeycardDetails: {
                d.observedKeycardUid = keycardUid
                root.profileSectionStore.backButtonName = root.mainSectionTitle
                root.sectionTitle = keycardName
                stackLayout.currentIndex = d.detailsViewIndex
            }
        }

        DetailsView {
            Layout.preferredWidth: root.contentWidth
            keycardStore: root.keycardStore
            keycardUid: d.observedKeycardUid
        }

        Connections {
            target: root.keycardStore.keycardModule

            onDisplayKeycardSharedModuleFlow: {
                keycardPopup.active = true
            }
            onDestroyKeycardSharedModuleFlow: {
                keycardPopup.active = false
            }

            onKeycardUidChanged: {
                if (d.observedKeycardUid === oldKcUid) {
                    d.observedKeycardUid = newKcUid
                }
            }
        }

        Loader {
            id: keycardPopup
            active: false
            sourceComponent: KeycardPopup {
                sharedKeycardModule: root.keycardStore.keycardModule.keycardSharedModule
            }

            onLoaded: {
                keycardPopup.item.open()
            }
        }
    }
}
