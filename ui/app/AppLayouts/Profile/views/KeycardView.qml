import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../stores"
import "./keycard"

SettingsContentBase {
    id: root

    property ProfileSectionStore profileSectionStore
    property KeycardStore keycardStore
    property var emojiPopup
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

            property string observedKeyUid: ""
        }

        MainView {
            Layout.preferredWidth: root.contentWidth
            keycardStore: root.keycardStore

            onDisplayKeycardsForKeypair: {
                root.keycardStore.keycardModule.prepareKeycardDetailsModel(keyUid)
                d.observedKeyUid = keyUid
                root.profileSectionStore.backButtonName = root.mainSectionTitle
                root.sectionTitle = keypairName
                stackLayout.currentIndex = d.detailsViewIndex
            }
        }

        DetailsView {
            Layout.preferredWidth: root.contentWidth
            keycardStore: root.keycardStore
            keyUid: d.observedKeyUid

            onChangeSectionTitle: {
                root.sectionTitle = title
            }

            onDetailsModelIsEmpty: {
                // if keypair is removed while user is in the details keycard view mode we need to go back to main keycard view
                root.handleBackAction()
            }
        }
    }
}
