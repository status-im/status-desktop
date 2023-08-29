import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.status 1.0
import shared.popups.keycard.helpers 1.0

import "../../stores"

ColumnLayout {
    id: root

    property KeycardStore keycardStore
    property string keyUid: ""

    signal changeSectionTitle(string title)
    signal detailsModelIsEmpty()

    spacing: Constants.settingsSection.itemSpacing

    QtObject {
        id: d
        property bool collapsed: true
        readonly property int numOfKeycards: root.keycardStore.keycardModule.keycardDetailsModel?
                                               root.keycardStore.keycardModule.keycardDetailsModel.count
                                             : 0

        onNumOfKeycardsChanged: {
            if (!!root.keycardStore.keycardModule.keycardDetailsModel && numOfKeycards === 0) {
                root.detailsModelIsEmpty()
            }
        }

        function checkAndCheckTitleIfNeeded(newKeycardName) {
            // We change title if there is only a single keycard for a keypair in keycard details view
            if (root.keycardStore.keycardModule.keycardDetailsModel.count === 1) {
                root.changeSectionTitle(newKeycardName)
            }
        }
    }

    StatusListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 250
        spacing: Style.current.padding
        model: root.keycardStore.keycardModule.keycardDetailsModel

        delegate: KeycardItem {
            width: ListView.view.width
            displayChevronComponent: false

            keycardName: model.keycard.name
            keycardUid: model.keycard.keycardUid
            keycardLocked: model.keycard.locked
            keyPairType: model.keycard.pairType
            keyPairIcon: model.keycard.icon
            keyPairImage: model.keycard.image
            keyPairAccounts: model.keycard.accounts

            onKeycardNameChanged: {
                d.checkAndCheckTitleIfNeeded(keycardName)
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Style.current.halfPadding
    }

    StatusSectionHeadline {
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
        text: qsTr("Configure your Keycard")
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Rename Keycard")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runRenameKeycardPopup(root.keyUid)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Change PIN")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runChangePinPopup(root.keyUid)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Create a backup copy of this Keycard")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runCreateBackupCopyOfAKeycardPopup(root.keyUid)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Stop using Keycard for this keypair")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runStopUsingKeycardPopup(root.keyUid)
        }
    }

    StatusListItem {
        visible: root.keycardStore.keycardModule.keycardDetailsModel?
                     root.keycardStore.keycardModule.keycardDetailsModel.lockedItemsCount > 0 : false
        Layout.fillWidth: true
        title: qsTr("Unlock Keycard")
        components: [
            StatusBadge {
                value: root.keycardStore.keycardModule.keycardDetailsModel?
                           root.keycardStore.keycardModule.keycardDetailsModel.lockedItemsCount : 0
                border.width: 4
                border.color: Theme.palette.dangerColor1
                color: Theme.palette.dangerColor1
            },
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runUnlockKeycardPopupForKeycardWithUid(root.keyUid)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Advanced")
        statusListItemTitle.color: Style.current.secondaryText
        components: [
            StatusIcon {
                icon: d.collapsed? "tiny/chevron-down" : "tiny/chevron-up"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            d.collapsed = !d.collapsed
       }
    }

    StatusListItem {
        visible: !d.collapsed
        Layout.fillWidth: true
        title: qsTr("Create a 12-digit personal unblocking key (PUK)")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runCreatePukPopup(root.keyUid)
        }
    }

    StatusListItem {
        visible: !d.collapsed
        enabled: false // This is post MVP feature, issue #8065
        Layout.fillWidth: true
        title: qsTr("Create a new pairing code")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runCreateNewPairingCodePopup(root.keyUid)
        }
    }
}
