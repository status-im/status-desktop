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
    property string keycardUid: ""

    spacing: Constants.settingsSection.itemSpacing

    QtObject {
        id: d
        property bool collapsed: true
        property string keyUid: ""

        function resetKeycardDetails() {
            let kcItem = root.keycardStore.getKeycardDetailsAsJson(root.keycardUid)
            d.keyUid = kcItem.keyUid
            keycardDetails.keycardName = kcItem.name
            keycardDetails.keycardLocked = kcItem.locked
            keycardDetails.keyPairType = kcItem.pairType
            keycardDetails.keyPairIcon = kcItem.icon
            keycardDetails.keyPairImage = kcItem.image
            keycardDetails.keyPairAccounts = kcItem.accounts
        }
    }

    onKeycardUidChanged: {
        d.resetKeycardDetails()
    }

    Connections {
        target: root.keycardStore.keycardModule

        onKeycardProfileChanged: {
            if (keycardDetails.keyPairType === Constants.keycard.keyPairType.profile) {
                d.resetKeycardDetails()
            }
        }

        onKeycardDetailsChanged: {
            if (kcUid === root.keycardUid) {
                d.resetKeycardDetails()
            }
        }
    }

    KeycardItem {
        id: keycardDetails
        Layout.fillWidth: true
        displayChevronComponent: false
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
            root.keycardStore.runRenameKeycardPopup(root.keycardUid, d.keyUid)
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
            root.keycardStore.runChangePinPopup()
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
            root.keycardStore.runCreateBackupCopyOfAKeycardPopup()
        }
    }

    StatusListItem {
        visible: keycardDetails.keycardLocked
        Layout.fillWidth: true
        title: qsTr("Unlock Keycard")
        components: [
            StatusBadge {
                value: 1 //always set to 1 if keycard is locked
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
            root.keycardStore.runUnlockKeycardPopupForKeycardWithUid(root.keycardUid)
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
            root.keycardStore.runCreatePukPopup()
        }
    }

    StatusListItem {
        visible: !d.collapsed
        Layout.fillWidth: true
        title: qsTr("Create a new pairing code")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runCreateNewPairingCodePopup()
        }
    }
}
