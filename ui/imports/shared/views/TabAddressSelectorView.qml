import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../panels"
import "../controls"
import "../views"

Item {
    id: root
    clip: true
    height: accountSelectionTabBar.height + stackLayout.height + Style.current.xlPadding

    property var store

    signal contactSelected(string address, int type)

    StatusTabBar {
        id: accountSelectionTabBar
        anchors.top: parent.top
        anchors.topMargin: 20
        width: parent.width
        
        StatusTabButton {
            id: assetBtn
            width: implicitWidth
            text: qsTr("Saved")
        }
        StatusTabButton {
            id: collectiblesBtn
            width: implicitWidth
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
        height: currentIndex === 0 ? savedAddresses.height: currentIndex === 1 ? myAccounts.height : recents.height
        width: parent.width
        currentIndex: accountSelectionTabBar.currentIndex

        // To-do adapt to new design and make block white/balck once the list items etc support new color scheme
        Rectangle {
            Layout.maximumWidth: parent.width
            Layout.maximumHeight : savedAddresses.height
            color: "transparent"
            radius: 8

            ListView {
                id: savedAddresses
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width
                height: Math.min(288, savedAddresses.contentHeight)

                model: root.store.savedAddressesModel
                clip: true
                header:  savedAddresses.count > 0 ? search : nothingInList
                headerPositioning: ListView.OverlayHeader
                boundsBehavior: Flickable.StopAtBounds
                delegate: StatusListItem {
                    width: visible ? parent.width:  0
                    height: visible ? 64 : 0
                    title: name
                    subTitle: address
                    radius: 0
                    visible: !savedAddresses.headerItem.text || name.toLowerCase().includes(savedAddresses.headerItem.text)
                    components: [
                        StatusIcon {
                            icon: "star-icon"
                            width: 12
                            height: 12
                        }
                    ]
                    onClicked: contactSelected(address, RecipientSelector.Type.Address )
                }
                Component {
                    id: search
                    StatusBaseInput {
                        width: parent.width
                        height: 56
                        placeholderText: qsTr("Search for saved address")
                        rightComponent: StatusIcon {
                            icon: "search"
                            height: 17
                            color: Theme.palette.baseColor1
                        }
                    }
                }
                Component {
                    id: nothingInList
                    StatusBaseText {
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                        text: qsTr("No Saved Address")
                    }
                }
            }
        }
        Rectangle {
            id: myAccountsRect
            Layout.maximumWidth: parent.width
            Layout.maximumHeight : myAccounts.height
            color: "transparent"
            radius: 8

            ListView {
                id: myAccounts
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width
                height: Math.min(288, myAccounts.contentHeight)

                boundsBehavior: Flickable.StopAtBounds
                clip: true

                delegate: StatusListItem {
                    width: visible ? parent.width:  0
                    height: visible ? 64 : 0
                    title: model.name
                    subTitle: Utils.toLocaleString(model.currencyBalance.toFixed(2), store.locale, {"model.currency": true}) + " " + store.currentCurrency.toUpperCase()
                    icon.emoji: !!model.emoji ? model.emoji: ""
                    icon.color: model.color
                    icon.name: !model.emoji ? "filled-account": ""
                    icon.letterSize: 14
                    icon.isLetterIdenticon: !!model.emoji ? true : false
                    icon.background.color: Theme.palette.indirectColor1
                    radius: 0
                    onClicked: contactSelected(model.address, RecipientSelector.Type.Account )
                }

                model: root.store.accounts
            }
        }

        Rectangle {
            Layout.maximumWidth: parent.width
            Layout.maximumHeight : recents.height
            color: "transparent"
            radius: 8

            ListView {
                id: recents
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: parent.width
                height: Math.min(288, recents.contentHeight)

                boundsBehavior: Flickable.StopAtBounds
                clip: true

                header: StatusBaseText {
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    text: qsTr("No Recents")
                    visible: recents.count <= 0
                }

                delegate: StatusListItem {
                    property bool isIncoming: to === store.currentAccount.address
                    width: visible ? parent.width:  0
                    height: visible ? 64 : 0
                    title: isIncoming ? from : to
                    subTitle: Utils.getTimeDifference(new Date(parseInt(timestamp) * 1000), new Date())
                    statusListItemTitle.elide: Text.ElideMiddle
                    statusListItemTitle.wrapMode: Text.NoWrap
                    radius: 0
                    components: [
                        StatusIcon {
                            id: transferIcon
                            height: 15
                            width: 15
                            color: isIncoming ? Style.current.success : Style.current.danger
                            icon: isIncoming ? "arrow-down" : "arrow-up"
                            rotation: 45
                        },
                        StatusBaseText {
                            id: contactsLabel
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                            text: store.hex2Eth(value)
                        }
                    ]
                    onClicked: contactSelected(title, RecipientSelector.Type.Address)
                }

                model: root.store.walletSectionTransactionsInst.model
            }
        }
    }
}
