import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils
import shared.status
import shared.popups.keycard.helpers

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
    }

    StatusListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 250
        spacing: Theme.padding
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
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.halfPadding
    }

    StatusSectionHeadline {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
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
        title: qsTr("Stop using Keycard for this key pair")
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
        statusListItemTitle.color: Theme.palette.secondaryText
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
