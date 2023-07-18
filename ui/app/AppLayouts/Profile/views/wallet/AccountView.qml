import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import shared.popups 1.0
import shared.panels 1.0
import utils 1.0

import "../../popups"
import "../../controls"

ColumnLayout {
    id: root

    signal goBack

    property var account
    property var keyPair
    property var walletStore
    property var emojiPopup
    property string userProfilePublicKey

    QtObject {
        id: d
        property bool watchOnlyAccount: keyPair && keyPair.pairType === Constants.keycard.keyPairType.watchOnly
        property bool privateKeyAccount: keyPair && keyPair.pairType === Constants.keycard.keyPairType.privateKeyImport
    }

    spacing: 0

    RowLayout {
        Layout.preferredWidth: parent.width
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.smallPadding
            StatusBaseText {
                id: accountName
                objectName: "walletAccountViewAccountName"
                Layout.alignment: Qt.AlignLeft
                text: root.account ? root.account.name : ""
                font.weight: Font.Bold
                font.pixelSize: 28
                color: root.account ? Utils.getColorForId(root.account.colorId) : Theme.palette.directColor1
            }
            StatusEmoji {
                id: accountImage
                objectName: "walletAccountViewAccountImage"
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                emojiId: StatusQUtils.Emoji.iconId(root.account && root.account.emoji ? root.account.emoji : "", StatusQUtils.Emoji.size.big) || ""
            }
        }
        StatusButton {
            Layout.alignment: Qt.AlignRight
            objectName: "walletAccountViewEditAccountButton"
            text: qsTr("Edit account")
            icon.name: "edit_pencil"
            onClicked: Global.openPopup(renameAccountModalComponent)
        }
    }

    StatusBaseText {
        Layout.topMargin: Style.current.bigPadding
        text: qsTr("Account details")
        font.pixelSize: 15
        color: Theme.palette.baseColor1
    }

    Rectangle {
        Layout.topMargin: Style.current.halfPadding
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        radius: Style.current.radius
        border.width: 1
        border.color: Theme.palette.directColor8
        color: Theme.palette.transparent

        ColumnLayout {
            width: parent.width
            spacing: 0
            WalletAccountDetailsListItem {
                Layout.fillWidth: true
                title: qsTr("Balance")
                subTitle: root.account && root.account.balance ? LocaleUtils.currencyAmountToLocaleString(root.account.balance): ""
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
            }
            WalletAccountDetailsListItem {
                Layout.fillWidth: true
                title: qsTr("Address")
                subTitle: {
                    let address = root.account && root.account.address ? root.account.address: ""
                    d.watchOnlyAccount ? address : WalletUtils.colorizedChainPrefix(walletStore.getAllNetworksSupportedPrefix()) + address
                }
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
            }
            StatusBaseText {
                text: qsTr("Keypair")
                Layout.leftMargin: 16
                Layout.topMargin: 12
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                visible: !d.watchOnlyAccount
            }
            WalletAccountDetailsKeypairItem {
                Layout.fillWidth: true
                keyPair: root.keyPair
                visible: !d.watchOnlyAccount
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
                visible: !d.watchOnlyAccount
            }
            WalletAccountDetailsListItem {
                Layout.fillWidth: true
                title: qsTr("Origin")
                subTitle: {
                    if(keyPair) {
                        switch(keyPair.pairType) {
                        case Constants.keycard.keyPairType.profile:
                            return qsTr("Derived from your default Status keypair")
                        case Constants.keycard.keyPairType.seedImport:
                            return qsTr("Imported from seed phrase")
                        case Constants.keycard.keyPairType.privateKeyImport:
                            return qsTr("Imported from private key")
                        case Constants.keycard.keyPairType.watchOnly:
                            return qsTr("Watched address")
                        default:
                            return ""
                        }
                    }
                    return ""
                }
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
            }
            WalletAccountDetailsListItem {
                id: derivationPath
                Layout.fillWidth: true
                title: qsTr("Derivation Path")
                subTitle: root.account ? Utils.getPathForDisplay(root.account.path) : ""
                visible: !!subTitle && !d.privateKeyAccount
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
                visible: derivationPath.visible
            }
            WalletAccountDetailsListItem {
                Layout.fillWidth: true
                title: qsTr("Stored")
                subTitle: keyPair && keyPair.migratedToKeycard ? qsTr("On Keycard"): qsTr("On device")
            }
        }
    }

    Separator {
        Layout.topMargin: 40
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.palette.baseColor2
    }

    RowLayout {
        Layout.topMargin: 20
        Layout.fillWidth: true
        spacing: 8
        StatusButton {
            Layout.fillWidth: true
            visible: !d.watchOnlyAccount && !d.privateKeyAccount
            text: keyPair && keyPair.migratedToKeycard? qsTr("Stop using Keycard") : qsTr("Migrate to Keycard")
            icon.name: "keycard"
            onClicked: {
                if (keyPair && keyPair.migratedToKeycard)
                    console.warn("TODO: stop using Keycard")
                else
                    console.warn("TODO: move keys to a Keycard")
            }
        }
        StatusButton {
            Layout.fillWidth: true
            objectName: "deleteAccountButton"
            visible: !!root.account && !root.account.isDefaultAccount
            text: qsTr("Remove account")
            icon.name: "delete"
            type: StatusBaseButton.Type.Danger
            onClicked: confirmationPopup.open()

            ConfirmationDialog {
                id: confirmationPopup
                confirmButtonObjectName: "confirmDeleteAccountButton"
                headerSettings.title: qsTr("Confirm %1 Removal").arg(root.account ? root.account.name : "")
                confirmationText: qsTr("You will not be able to restore viewing access to this account in the future unless you enter this account’s address again.")
                confirmButtonLabel: qsTr("Remove Account")
                onConfirmButtonClicked: {
                    root.walletStore.deleteAccount(root.account.address);
                    confirmationPopup.close()
                    root.goBack()
                }
            }
        }
    }
    Component {
        id: renameAccountModalComponent
        RenameAccontModal {
            account: root.account
            anchors.centerIn: parent
            onClosed: destroy()
            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
        }
    }
}
