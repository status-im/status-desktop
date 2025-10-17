import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

import utils

import "../stores"
import "./keycard"

SettingsContentBase {
    id: root

    property KeycardStore keycardStore
    property var emojiPopup
    property string mainSectionTitle: ""
    property string backButtonName

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Get Keycard")
        onClicked: {
            Global.requestOpenLink(Constants.keycard.general.purchasePage)
        }
    }

    function handleBackAction() {
        if (stackLayout.currentIndex === d.detailsViewIndex) {
            root.backButtonName = ""
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
                root.backButtonName = root.mainSectionTitle
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
