import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.1

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0 as SharedControls
// TODO: remove all files and dependecies with this location once old send modal is removed
import shared.popups.send.controls 1.0
import shared.popups.send 1.0

import utils 1.0

import AppLayouts.Wallet.views 1.0

Rectangle {
    id: root

    required property var savedAddressesModel
    required property var myAccountsModel
    required property var recentRecipientsModel

    property alias selectedRecipientAddress: recipientInputLoader.selectedRecipientAddress
    property alias selectedRecipientType: recipientInputLoader.selectedRecipientType

    signal resolveENS(string ensName, string uuid)

    function ensNameResolved(resolvedPubKey, resolvedAddress, uuid) {
        recipientInputLoader.ensNameResolved(resolvedPubKey, resolvedAddress, uuid)
    }

    implicitHeight: childrenRect.height
    color: Theme.palette.indirectColor1
    radius: 8

    ColumnLayout {
        id: layout

        width: parent.width
        spacing: 0

        RecipientView {
            id: recipientInputLoader

            Layout.fillWidth: true

            savedAddressesModel: root.savedAddressesModel
            myAccountsModel: root.myAccountsModel

            onResolveENS: root.resolveENS(ensName, uuid)
        }

        StatusTabBar {
            id: recipientTypeTabBar

            objectName: "recipientTypeTabBar"

            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.topMargin: 12

            StatusTabButton {
                width: implicitWidth
                objectName: "recentAddressesTab"
                text: qsTr("Recent")
            }
            StatusTabButton {
                width: implicitWidth
                objectName: "savedAddressesTab"
                text: qsTr("Saved")
            }
            StatusTabButton {
                width: implicitWidth
                objectName: "myAccountsTab"
                text: qsTr("My Accounts")
            }

            visible: !root.selectedRecipientAddress
        }

        Repeater {
            id: repeater

            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            model:  {
                switch(recipientTypeTabBar.currentIndex) {
                case 0:
                    return recentsObjModel
                case 1:
                    return savedObjModel
                case 2:
                    return myAccountsObjModel
                }
            }
        }
    }

    DelegateModel {
        id: recentsObjModel

        model: root.recentRecipientsModel
        delegate: StatusListItem {
            id: listItem

            property var entry: model.activityEntry
            property bool isIncoming: entry.txType === Constants.TransactionType.Receive

            Layout.fillWidth: true
            title: isIncoming ? StatusQUtils.Utils.elideText(entry.sender,6,4) : StatusQUtils.Utils.elideText(entry.recipient,6,4)
            subTitle: LocaleUtils.getTimeDifference(new Date(parseInt(entry.timestamp) * 1000), new Date())
            statusListItemTitle.elide: Text.ElideMiddle
            statusListItemTitle.wrapMode: Text.NoWrap
            radius: 0
            color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"
            statusListItemComponentsSlot.spacing: 5
            components: [
                StatusIcon {
                    id: transferIcon
                    height: 15
                    width: 15
                    color: listItem.isIncoming ? Theme.palette.successColor1 : Theme.palette.dangerColor1
                    icon: listItem.isIncoming ? "arrow-down" : "arrow-up"
                    rotation: 45
                },
                StatusTextWithLoadingState {
                    text: LocaleUtils.currencyAmountToLocaleString(entry.amountCurrency)
                }
            ]
            onClicked: {
                root.selectedRecipientType = Helpers.RecipientAddressObjectType.RecentsAddress
                let isIncoming = entry.txType === Constants.TransactionType.Receive
                let selectedAddress =  isIncoming ? entry.sender : entry.recipient
                root.selectedRecipientAddress = selectedAddress
            }
            visible: !root.selectedRecipientAddress
        }
    }

    DelegateModel {
        id: savedObjModel

        model: root.savedAddressesModel
        delegate: SavedAddressListItem {
            Layout.fillWidth: true
            modelData: model
            onClicked: {
                root.selectedRecipientType = Helpers.RecipientAddressObjectType.SavedAddress
                root.selectedRecipientAddress = modelData.address
            }
            visible: !root.selectedRecipientAddress
        }
    }

    DelegateModel {
        id: myAccountsObjModel

        model: root.myAccountsModel
        delegate: SharedControls.WalletAccountListItem {
            required property var model

            Layout.fillWidth: true

            name: model.name
            address: model.address
            emoji: model.emoji
            walletColor: Utils.getColorForId(model.colorId)
            currencyBalance: model.currencyBalance
            walletType: model.walletType
            migratedToKeycard: model.migratedToKeycard ?? false
            accountBalance: model.accountBalance ?? null
            onClicked: {
                root.selectedRecipientType = Helpers.RecipientAddressObjectType.Account
                root.selectedRecipientAddress = model.address
            }
            visible: !root.selectedRecipientAddress
        }
    }
}
