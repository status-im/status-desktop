import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
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
    clip: true
    implicitHeight: visible ? accountSelectionTabBar.height + stackLayout.height + Style.current.bigPadding: 0

    property var selectedAccount
    property var store

    signal recipientSelected(var recipient, int type)

    enum Type {
        Address,
        Contact,
        Account,
        SavedAddress,
        RecentsAddress,
        None
    }

    QtObject {
        id: d
        readonly property int maxHeightForList: 281
    }

    StatusTabBar {
        id: accountSelectionTabBar
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        
        StatusTabButton {
            id: assetBtn
            width: implicitWidth
            text: qsTr("Saved")
        }
        StatusTabButton {
            id: collectiblesBtn
            width: implicitWidth
            objectName: "myAccountsTab"
            text: qsTr("My Accounts")
        }
        StatusTabButton {
            id: historyBtn
            width: implicitWidth
            text: qsTr("Recent")
        }
    }

    StackLayout {
        id: stackLayout
        anchors.top: accountSelectionTabBar.bottom
        anchors.topMargin: -5
        height: currentIndex === 0 ? savedAddresses.height: currentIndex === 1 ? myAccounts.height : recents.height
        width: parent.width
        currentIndex: accountSelectionTabBar.currentIndex

        // To-do adapt to new design and make block white/balck once the list items etc support new color scheme
        Rectangle {
            Layout.maximumWidth: parent.width
            Layout.maximumHeight : savedAddresses.height
            color: Theme.palette.indirectColor1
            radius: 8

            StatusListView {
                id: savedAddresses
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                implicitWidth: parent.width
                height: Math.min(d.maxHeightForList, savedAddresses.contentHeight)

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
        }
        Rectangle {
            id: myAccountsRect
            Layout.maximumWidth: parent.width
            Layout.maximumHeight : myAccounts.height
            color: Theme.palette.indirectColor1
            radius: 8

            StatusListView {
                id: myAccounts
                objectName: "myAccountsList"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width
                height: Math.min(d.maxHeightForList, myAccounts.contentHeight)

                delegate: WalletAccountListItem {
                    implicitWidth: ListView.view.width
                    modelData: model
                    chainShortNames: root.store.getAllNetworksSupportedPrefix()
                    onClicked: recipientSelected({name: modelData.name,
                                                     address: modelData.address,
                                                     color: modelData.color,
                                                     emoji: modelData.emoji,
                                                     walletType: modelData.walletType,
                                                     currencyBalance: modelData.currencyBalance}, TabAddressSelectorView.Type.Account )
                }

                model: root.store.accounts
            }
        }

        Rectangle {
            Layout.maximumWidth: parent.width
            Layout.maximumHeight : recents.height
            color: Theme.palette.indirectColor1
            radius: 8

            StatusListView {
                id: recents
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width
                height: Math.min(d.maxHeightForList, recents.contentHeight)

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
                    property bool isIncoming: root.selectedAccount ? to === root.selectedAccount.address : false
                    implicitWidth: ListView.view.width
                    height: visible ? 64 : 0
                    title: loading ? Constants.dummyText : isIncoming ? StatusQUtils.Utils.elideText(from,6,4) : StatusQUtils.Utils.elideText(to,6,4)
                    subTitle: LocaleUtils.getTimeDifference(new Date(parseInt(timestamp) * 1000), new Date())
                    statusListItemTitle.elide: Text.ElideMiddle
                    statusListItemTitle.wrapMode: Text.NoWrap
                    radius: 0
                    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"
                    statusListItemComponentsSlot.spacing: 5
                    loading: loadingTransaction
                    components: [
                        StatusIcon {
                            id: transferIcon
                            height: 15
                            width: 15
                            color: isIncoming ? Style.current.success : Style.current.danger
                            icon: isIncoming ? "arrow-down" : "arrow-up"
                            rotation: 45
                            visible: !listItem.loading
                        },
                        StatusTextWithLoadingState {
                            id: contactsLabel
                            loading: listItem.loading
                            font.pixelSize: 15
                            customColor: Theme.palette.directColor1
                            text: loading ? Constants.dummyText : LocaleUtils.currencyAmountToLocaleString(value)
                        }
                    ]
                    onClicked: recipientSelected(model, TabAddressSelectorView.Type.RecentsAddress)
                }

                model: {
                    if(root.selectedAccount) {
                        root.store.prepareTransactionsForAddress(root.selectedAccount.address)
                        return root.store.getTransactions()
                    }
                }
            }
        }
    }
}
