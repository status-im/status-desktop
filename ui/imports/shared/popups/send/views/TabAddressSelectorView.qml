import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.controls 1.0 as SharedControls
import shared.stores 1.0

import AppLayouts.Wallet 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../panels"
import "../controls"
import "../views"

Item {
    id: root

    property var selectedAccount
    property var store

    signal recipientSelected(var recipient, int type)

    enum Type {
        Address,
        Account,
        SavedAddress,
        RecentsAddress,
        None
    }

    QtObject {
        id: d

        // Use Layer1 controller since this could go on top of other activity lists
        readonly property var activityController: root.store.tmpActivityController1
    }

    StatusTabBar {
        id: accountSelectionTabBar
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Saved")
        }
        StatusTabButton {
            width: implicitWidth
            objectName: "myAccountsTab"
            text: qsTr("My Accounts")
        }
        StatusTabButton {
            width: implicitWidth
            text: qsTr("Recent")
        }
    }

    // To-do adapt to new design and make block white/black once the list items etc support new color scheme
    Rectangle {
        anchors.top: accountSelectionTabBar.bottom
        anchors.topMargin: -5
        height: parent.height - accountSelectionTabBar.height
        width: parent.width
        color: Theme.palette.indirectColor1
        radius: 8

        StackLayout {
            currentIndex: accountSelectionTabBar.currentIndex

            anchors.fill: parent

            StatusListView {
                id: savedAddresses

                model: root.store.savedAddressesModel
                header: savedAddresses.count > 0 ? search : nothingInList
                headerPositioning: ListView.OverlayHeader
                delegate: SavedAddressListItem {
                    implicitWidth: ListView.view.width
                    modelData: model
                    visible: !savedAddresses.headerItem.text || name.toLowerCase().includes(savedAddresses.headerItem.text)
                    onClicked: recipientSelected(modelData, TabAddressSelectorView.Type.SavedAddress)
                }
                Component {
                    id: search
                    SearchBoxWithRightIcon {
                        width: parent.width
                        placeholderText: qsTr("Search for saved address")
                        z: 2
                    }
                }
                Component {
                    id: nothingInList
                    StatusBaseText {
                        width: savedAddresses.width
                        height: visible ? 56 : 0
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                        text: qsTr("No Saved Address")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            StatusListView {
                id: myAccounts
                objectName: "myAccountsList"

                delegate: SharedControls.WalletAccountListItem {
                    required property var model

                    implicitWidth: ListView.view.width
                    name: model.name
                    address: model.address

                    emoji: model.emoji
                    walletColor: Utils.getColorForId(model.colorId)
                    currencyBalance: model.currencyBalance
                    walletType: model.walletType
                    migratedToKeycard: model.migratedToKeycard ?? false
                    accountBalance: model.accountBalance ?? null
                    chainShortNames: {
                        const chainShortNames = store.getNetworkShortNames(model.preferredSharingChainIds)
                        return WalletUtils.colorizedChainPrefix(chainShortNames)
                    }
                    onClicked: recipientSelected({name: model.name,
                                                     address: model.address,
                                                     colorId: model.colorId,
                                                     emoji: model.emoji,
                                                     walletType: model.walletType,
                                                     currencyBalance: model.currencyBalance,
                                                     preferredSharingChainIds: model.preferredSharingChainIds,
                                                     migratedToKeycard: model.migratedToKeycard
                                                 },
                                                 TabAddressSelectorView.Type.Account)
                }

                model: root.store.accounts
            }

            StatusListView {
                id: recents

                header: StatusBaseText {
                    height: visible ? 56 : 0
                    width: recents.width
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    text: qsTr("No Recents")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: recents.count <= 0
                }

                delegate: StatusListItem {
                    id: listItem

                    property var entry: activityEntry
                    property bool isIncoming: entry.txType === Constants.TransactionType.Receive

                    implicitWidth: ListView.view.width
                    height: visible ? 64 : 0
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
                            color: listItem.isIncoming ? Style.current.success : Style.current.danger
                            icon: listItem.isIncoming ? "arrow-down" : "arrow-up"
                            rotation: 45
                        },
                        StatusTextWithLoadingState {
                            font.pixelSize: 15
                            customColor: Theme.palette.directColor1
                            text: LocaleUtils.currencyAmountToLocaleString(entry.amountCurrency)
                        }
                    ]
                    onClicked: recipientSelected(entry, TabAddressSelectorView.Type.RecentsAddress)
                }

                model: d.activityController.model

                onVisibleChanged: {
                    if (visible) {
                        updateRecentsActivity()
                    }
                }

                Connections {
                    target: root
                    function onSelectedAccountChanged() {
                        if (visible) {
                            recents.updateRecentsActivity()
                        }
                    }
                }

                function updateRecentsActivity() {
                    if(root.selectedAccount) {
                        d.activityController.setFilterAddressesJson(JSON.stringify([root.selectedAccount.address]), false)
                    }
                    d.activityController.updateFilter()
                }
            }
        }
    }
}
