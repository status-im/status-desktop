import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import SortFilterProxyModel 0.2

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.popups 1.0
import shared.popups.keycard 1.0
import shared.stores 1.0

import "../controls"
import "../popups"
import "../stores"
import "../addaccount"

Rectangle {
    id: root
    objectName: "walletLeftTab"

    property var networkConnectionStore
    property var selectAllAccounts: function(){}
    property var changeSelectedAccount: function(){}
    property bool showSavedAddresses: false
    property bool showAllAccounts: true
    property string currentAddress: ""
    
    onShowSavedAddressesChanged: {
        root.currentAddress = ""
        walletAccountsListView.headerItem.highlighted = root.showAllAccounts
        walletAccountsListView.footerItem.button.highlighted = root.showSavedAddresses
    }

    onShowAllAccountsChanged: {
        root.currentAddress = ""
        walletAccountsListView.headerItem.highlighted = root.showAllAccounts
        walletAccountsListView.footerItem.button.highlighted = root.showSavedAddresses
    }

    property var emojiPopup: null

    color: Style.current.secondaryMenuBackground

    Loader {
        id: addAccount
        active: false
        asynchronous: true

        sourceComponent: AddAccountPopup {
            store.emojiPopup: root.emojiPopup
            store.addAccountModule: walletSection.addAccountModule
        }

        onLoaded: {
            addAccount.item.open()
        }
    }

    Loader {
        id: walletBckgAccountContextMenu
        sourceComponent: AccountContextMenu {

            uniqueIdentifier: "wallet-background"

            onClosed: {
                walletBckgAccountContextMenu.active = false
            }

            onAddNewAccountClicked: {
                RootStore.runAddAccountPopup()
            }

            onAddWatchOnlyAccountClicked: {
                RootStore.runAddWatchOnlyAccountPopup()
            }
        }
    }

    Loader {
        id: removeAccountConfirmation
        active: false

        property bool simple
        property string accountKeyUid
        property string accountName
        property string accountAddress
        property string accountDerivationPath

        sourceComponent: RemoveAccountConfirmationPopup {
            simple: removeAccountConfirmation.simple
            accountName: removeAccountConfirmation.accountName
            accountAddress: removeAccountConfirmation.accountAddress
            accountDerivationPath: removeAccountConfirmation.accountDerivationPath

            onClosed: {
                removeAccountConfirmation.active = false
            }

            onRemoveAccount: {
                close()
                RootStore.deleteAccount(address)
            }
        }

        onLoaded: {
            removeAccountConfirmation.item.open()
        }
    }

    Connections {
        target: walletSection

        function onDisplayAddAccountPopup() {
            addAccount.active = true
        }
        function onDestroyAddAccountPopup() {
            addAccount.active = false
        }
        function onFilterChanged(address, excludeWatchOnly, allAddresses) {
            root.currentAddress = allAddresses ? "" : address
            root.showAllAccounts = allAddresses
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                walletBckgAccountContextMenu.active = true
                walletBckgAccountContextMenu.item.popup(mouse.x, mouse.y)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: walletTitleText.height
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            Layout.topMargin: Style.current.padding

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    mouse.accepted = true
                }
            }

            StatusBaseText {
                id: walletTitleText
                text: qsTr("Wallet")
                font.weight: Font.Bold
                font.pixelSize: 17
                color: Theme.palette.directColor1
            }

            StatusRoundButton {
                objectName: "addAccountButton"
                icon.name: "add-circle"
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 2
                color: hovered || highlighted ? Theme.palette.primaryColor3
                                              : "transparent"
                onClicked: RootStore.runAddAccountPopup()
            }
        }

        StatusListView {
            id: walletAccountsListView

            objectName: "walletAccountsListView"
            spacing: Style.current.smallPadding
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Style.current.halfPadding

            // ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            readonly property Item firstItem: count > 0 ? itemAtIndex(0) : null

            delegate: StatusListItem {
                objectName: "walletAccount-" + model.name
                readonly property bool itemLoaded: !model.assetsLoading // needed for e2e tests
                width: ListView.view.width - Style.current.padding * 2
                highlighted: root.currentAddress.toLowerCase() === model.address.toLowerCase()
                anchors.horizontalCenter: !!parent ? parent.horizontalCenter : undefined
                title: model.name
                subTitle: LocaleUtils.currencyAmountToLocaleString(model.currencyBalance)
                asset.emoji: !!model.emoji ? model.emoji: ""
                asset.color: Utils.getColorForId(model.colorId)
                asset.name: !model.emoji ? "filled-account": ""
                asset.width: 40
                asset.height: 40
                asset.letterSize: 14
                asset.isLetterIdenticon: !!model.emoji ? true : false
                asset.bgColor: Theme.palette.primaryColor3
                statusListItemTitle.font.weight: Font.Medium
                color: sensor.containsMouse || highlighted ? Theme.palette.baseColor3 : "transparent"
                statusListItemSubTitle.loading: !!model.assetsLoading
                errorMode: networkConnectionStore.accountBalanceNotAvailable
                errorIcon.tooltip.maxWidth: 300
                errorIcon.tooltip.text: networkConnectionStore.accountBalanceNotAvailableText
                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        accountContextMenu.active = true
                        accountContextMenu.item.popup(mouse.x, mouse.y)
                        return
                    }
                    root.showSavedAddresses = false
                    root.showAllAccounts = false
                    changeSelectedAccount(model.address)
                }
                components: [
                    StatusIcon {
                        width: !!icon ? 15: 0
                        height: !!icon ? 15: 0
                        color: Theme.palette.directColor1
                        icon: model.walletType === Constants.watchWalletType ? "show" : ""
                    },
                    StatusIcon {
                        width: !!icon ? 15: 0
                        height: !!icon ? 15: 0
                        color: Theme.palette.directColor1
                        icon: model.keycardAccount ? "keycard" : ""
                    }
                ]

                Loader {
                    id: accountContextMenu
                    sourceComponent: AccountContextMenu {

                        uniqueIdentifier: model.name
                        account: model

                        onClosed: {
                            accountContextMenu.active = false
                        }

                        onEditAccountClicked: {
                            RootStore.runEditAccountPopup(model.address)
                        }

                        onDeleteAccountClicked: {
                            removeAccountConfirmation.simple = model.walletType === Constants.watchWalletType || model.walletType === Constants.keyWalletType
                            removeAccountConfirmation.accountName = model.name
                            removeAccountConfirmation.accountAddress = model.address
                            removeAccountConfirmation.accountDerivationPath = model.path
                            removeAccountConfirmation.active = true
                        }

                        onAddNewAccountClicked: {
                            RootStore.runAddAccountPopup()
                        }

                        onAddWatchOnlyAccountClicked: {
                            RootStore.runAddWatchOnlyAccountPopup()
                        }
                    }
                }
            }

            readonly property bool footerOverlayed: contentHeight > availableHeight

            header: Button {
                id: header
                verticalPadding: Style.current.padding
                horizontalPadding: Style.current.padding
                highlighted: true
                objectName: "allAccountsBtn"
                
                leftInset: Style.current.padding
                bottomInset: Style.current.padding

                background: Rectangle {
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showSavedAddresses = false
                            root.selectAllAccounts()
                        }
                        hoverEnabled: true
                    }
                    radius: Style.current.radius
                    color: header.highlighted || mouseArea.containsMouse ? Style.current.backgroundHover : root.color
                    implicitWidth: parent.ListView.view.width - Style.current.padding * 2
                    implicitHeight: parent.ListView.view.firstItem.height + Style.current.padding

                    layer.effect: DropShadow {
                        verticalOffset: -10
                        radius: 20
                        samples: 41
                        fast: true
                        cached: true
                        color: Theme.palette.dropShadow2
                    }
                }

                contentItem: Item {
                    StatusBaseText {
                        id: allAccounts
                        leftPadding: Style.current.padding
                        color: Theme.palette.baseColor1
                        text: qsTr("All accounts")
                        font.weight: Font.Medium
                        font.pixelSize: 15
                    }

                    StatusTextWithLoadingState {
                        id: walletAmountValue
                        objectName: "walletLeftListAmountValue"
                        customColor: Style.current.textColor
                        text: {
                            LocaleUtils.currencyAmountToLocaleString(RootStore.totalCurrencyBalance)
                        }
                        font.pixelSize: 22
                        loading: RootStore.assetsLoading
                        visible: !networkConnectionStore.accountBalanceNotAvailable
                        anchors.top: allAccounts.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: Style.current.padding
                        leftPadding: Style.current.padding
                    }

                    StatusFlatRoundButton {
                        id: errorIcon
                        width: 14
                        height: visible ? 14 : 0
                        icon.width: 14
                        icon.height: 14
                        icon.name: "tiny/warning"
                        icon.color: Theme.palette.dangerColor1
                        tooltip.text: networkConnectionStore.accountBalanceNotAvailableText
                        tooltip.maxWidth: 200
                        visible: networkConnectionStore.accountBalanceNotAvailable
                    }
                }
            }

            footerPositioning: footerOverlayed ? ListView.OverlayFooter : ListView.InlineFooter
            footer: Control {
                id: footer

                z: 2 // to be on top of delegates when in ListView.OverlayFooter
                horizontalPadding: Style.current.padding
                verticalPadding: Style.current.padding

                property alias button: savedAddressesBtn

                background: Rectangle {
                    color: root.color
                    implicitWidth: root.width
                    implicitHeight: parent.ListView.view.firstItem.height + Style.current.xlPadding

                    layer.enabled: parent.ListView.view.footerOverlayed
                    layer.effect: DropShadow {
                        verticalOffset: -10
                        radius: 20
                        samples: 41
                        fast: true
                        cached: true
                        color: Theme.palette.dropShadow2
                    }

                    StatusMenuSeparator {
                        id: footerSeparator

                        width: parent.width
                        visible: !footer.ListView.view.footerOverlayed
                    }
                }

                contentItem: StatusFlatButton {
                    id: savedAddressesBtn

                    objectName: "savedAddressesBtn"
                    hoverColor: Theme.palette.primaryColor3
                    asset.bgColor: Theme.palette.primaryColor3
                    text: qsTr("Saved addresses")
                    icon.name: "address"
                    icon.width: 40
                    icon.height: 40
                    icon.color: Theme.palette.primaryColor1
                    isRoundIcon: true
                    textColor: Theme.palette.directColor1
                    textFillWidth: true
                    spacing: parent.ListView.view.firstItem.statusListItemTitleArea.anchors.leftMargin
                    onClicked: {
                        root.showAllAccounts = false
                        root.showSavedAddresses = true
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        propagateComposedEvents: true
                        onClicked: {
                            mouse.accepted = true
                        }
                    }
                }
            }

            model: SortFilterProxyModel {
                sourceModel: RootStore.accounts

                sorters: RoleSorter { roleName: "createdAt"; sortOrder: Qt.AscendingOrder }
            }
            
        }
    }
}
