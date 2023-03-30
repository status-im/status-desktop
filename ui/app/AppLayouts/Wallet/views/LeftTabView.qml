import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

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

    readonly property NetworkConnectionStore networkConnectionStore: NetworkConnectionStore {}
    property var changeSelectedAccount: function(){}
    property bool showSavedAddresses: false
    onShowSavedAddressesChanged: {
        walletAccountsListView.footerItem.button.highlighted = showSavedAddresses
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
            anchors.centerIn: parent
        }

        onLoaded: {
            addAccount.item.open()
        }
    }

    Loader {
        id: walletBckgAccountContextMenu
        sourceComponent: AccountContextMenu {
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
            anchors.centerIn: parent
            width: 400

            simple: removeAccountConfirmation.simple
            accountKeyUid: removeAccountConfirmation.accountKeyUid
            accountName: removeAccountConfirmation.accountName
            accountAddress: removeAccountConfirmation.accountAddress
            accountDerivationPath: removeAccountConfirmation.accountDerivationPath

            onClosed: {
                removeAccountConfirmation.active = false
            }

            onRemoveAccount: {
                close()
                RootStore.deleteAccount(keyUid, address)
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

        Item {
            height: childrenRect.height
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    mouse.accepted = true
                }
            }

            StyledTextEditWithLoadingState {
                id: walletAmountValue
                objectName: "walletLeftListAmountValue"
                customColor: Style.current.textColor
                text: {
                    LocaleUtils.currencyAmountToLocaleString(RootStore.totalCurrencyBalance)
                }
                selectByMouse: true
                cursorVisible: true
                readOnly: true
                width: parent.width
                font.weight: Font.Medium
                font.pixelSize: 22
                loading: RootStore.currentAccount.assetsLoading
                visible: !networkConnectionStore.tokenBalanceNotAvailable
            }

            StatusFlatRoundButton {
                id: errorIcon
                width: 14
                height: visible ? 14 : 0
                icon.width: 14
                icon.height: 14
                icon.name: "tiny/warning"
                icon.color: Theme.palette.dangerColor1
                tooltip.text: networkConnectionStore.tokenBalanceNotAvailableText
                tooltip.maxWidth: 200
                visible: networkConnectionStore.tokenBalanceNotAvailable
            }

            StatusBaseText {
                id: totalValue
                color: Theme.palette.baseColor1
                text: qsTr("Total value")
                width: parent.width
                anchors.top: walletAmountValue.bottom
                anchors.topMargin: 4
                font.pixelSize: 12
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
                objectName: "walletAccountItem"
                width: ListView.view.width - Style.current.padding * 2
                highlighted: !ListView.view.footerItem.button.highlighted &&
                             RootStore.currentAccount.name === model.name
                anchors.horizontalCenter: !!parent ? parent.horizontalCenter : undefined
                title: model.name
                subTitle: LocaleUtils.currencyAmountToLocaleString(model.currencyBalance)
                asset.emoji: !!model.emoji ? model.emoji: ""
                asset.color: model.color
                asset.name: !model.emoji ? "filled-account": ""
                asset.width: 40
                asset.height: 40
                asset.letterSize: 14
                asset.isLetterIdenticon: !!model.emoji ? true : false
                asset.bgColor: Theme.palette.primaryColor3
                statusListItemTitle.font.weight: Font.Medium
                color: sensor.containsMouse || highlighted ? Theme.palette.baseColor3 : "transparent"
                statusListItemSubTitle.loading: model.assetsLoading
                errorMode: networkConnectionStore.tokenBalanceNotAvailable
                errorIcon.tooltip.maxWidth: 300
                errorIcon.tooltip.text: networkConnectionStore.tokenBalanceNotAvailableText
                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        accountContextMenu.active = true
                        accountContextMenu.item.popup(mouse.x, mouse.y)
                        return
                    }
                    changeSelectedAccount(index)
                    showSavedAddresses = false
                }
                components: [
                    StatusIcon {
                        icon: {
                            if (model.walletType === Constants.watchWalletType)
                                return "show"
                            if (model.walletType === Constants.keyWalletType)
                                return "keycard"

                            return ""
                        }
                        color: Theme.palette.directColor1
                        width: 15
                        height: 15
                    }
                ]

                Loader {
                    id: accountContextMenu
                    sourceComponent: AccountContextMenu {
                        account: model

                        onEditAccountClicked: {
                        }

                        onDeleteAccountClicked: {
                            removeAccountConfirmation.simple = model.walletType === Constants.watchWalletType || model.walletType === Constants.keyWalletType
                            removeAccountConfirmation.accountKeyUid = model.keyUid
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

                contentItem: StatusButton {
                    id: savedAddressesBtn

                    objectName: "savedAddressesBtn"
                    size: StatusBaseButton.Size.Large
                    normalColor: "transparent"
                    hoverColor: Theme.palette.primaryColor3
                    asset.color: Theme.palette.primaryColor1
                    asset.bgColor: Theme.palette.primaryColor3
                    font.weight: Font.Medium
                    text: qsTr("Saved addresses")
                    icon.name: "address"
                    icon.width: 40
                    icon.height: 40
                    isRoundIcon: true
                    textColor: Theme.palette.directColor1
                    textAlignment: Qt.AlignVCenter | Qt.AlignLeft
                    textFillWidth: true
                    spacing: parent.ListView.view.firstItem.statusListItemTitleArea.anchors.leftMargin
                    onClicked: {
                        showSavedAddresses = true
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        propagateComposedEvents: true
                        onClicked: {
                            mouse.accepted = true
                        }
                    }
                }
            }

            model: RootStore.accounts
            // model: RootStore.exampleWalletModel
        }
    }
}
