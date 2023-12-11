import QtQuick 2.15
import QtQuick.Controls 2.15
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
import shared.popups.addaccount 1.0
import shared.stores 1.0

import "../controls"
import "../popups"
import "../stores"

Rectangle {
    id: root
    objectName: "walletLeftTab"

    property var networkConnectionStore
    property var selectAllAccounts: function(){}
    property var changeSelectedAccount: function(){}
    property bool showSavedAddresses: false
    property bool showAllAccounts: true
    property string currentAddress: ""

    onCurrentAddressChanged: {
        if (!currentAddress)
            return
        root.showAllAccounts = false
        root.showSavedAddresses = false
    }
    
    onShowSavedAddressesChanged: {
        if (!showSavedAddresses)
            return
        root.currentAddress = ""
        root.showAllAccounts = false
    }

    onShowAllAccountsChanged: {
        if (!showAllAccounts)
            return
        root.currentAddress = ""
        root.showSavedAddresses = false
    }

    property var emojiPopup: null

    color: Style.current.secondaryMenuBackground

    Component.onCompleted: {
        d.loaded = true
    }

    QtObject {
        id: d
        property bool loaded: false
    }

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
        id: walletAccountContextMenu
        active: false
        sourceComponent: AccountContextMenu {

            onClosed: {
                walletAccountContextMenu.active = false
            }

            onAddNewAccountClicked: {
                RootStore.runAddAccountPopup()
            }

            onAddWatchOnlyAccountClicked: {
                RootStore.runAddWatchOnlyAccountPopup()
            }

            onEditAccountClicked: {
                if (!account)
                    return
                RootStore.runEditAccountPopup(account.address)
            }

            onDeleteAccountClicked: {
                if (!account)
                    return
                removeAccountConfirmation.accountType = account.walletType
                removeAccountConfirmation.accountName = account.name
                removeAccountConfirmation.accountAddress = account.address
                removeAccountConfirmation.accountDerivationPath = account.path
                removeAccountConfirmation.preferredSharingChainIds = account.preferredSharingChainIds
                removeAccountConfirmation.emoji = account.emoji
                removeAccountConfirmation.colorId = account.colorId
                removeAccountConfirmation.active = true
            }

            onHideFromTotalBalanceClicked: RootStore.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
        }
    }

    Loader {
        id: removeAccountConfirmation
        active: false

        property string accountType
        property string accountKeyUid
        property string accountName
        property string accountAddress
        property string accountDerivationPath
        property string preferredSharingChainIds
        property string emoji
        property string colorId

        sourceComponent: RemoveAccountConfirmationPopup {
            accountType: removeAccountConfirmation.accountType
            accountName: removeAccountConfirmation.accountName
            accountAddress: removeAccountConfirmation.accountAddress
            accountDerivationPath: removeAccountConfirmation.accountDerivationPath
            preferredSharingNetworkShortNames: RootStore.getNetworkShortNames(removeAccountConfirmation.preferredSharingChainIds)
            emoji: removeAccountConfirmation.emoji
            color: Utils.getColorForId(removeAccountConfirmation.colorId)

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
        function onFilterChanged(address, allAddresses) {
            root.currentAddress = allAddresses ? "" : address
            root.showAllAccounts = allAddresses
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                walletAccountContextMenu.active = true
                walletAccountContextMenu.item.popup(mouse.x, mouse.y)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: icon.height
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            Layout.topMargin: Style.current.padding

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: mouse.accepted = true
            }

            StatusBaseText {
                id: walletTitleText
                text: qsTr("Wallet")
                font.weight: Font.Bold
                font.pixelSize: 17
                color: Theme.palette.directColor1
                anchors.verticalCenter: parent.verticalCenter
            }

            StatusRoundButton {
                id: icon
                objectName: "addAccountButton"
                icon.name: "add-circle"
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                icon.width: 24
                icon.height: 24
                color: hovered || highlighted ? Theme.palette.primaryColor3
                                              : "transparent"
                onClicked: RootStore.runAddAccountPopup()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.minimumHeight: Style.current.bigPadding
            color: root.color
            z: 2

            layer.enabled: !walletAccountsListView.atYBeginning
            layer.effect: DropShadow {
                verticalOffset: 10
                radius: 20
                samples: 41
                fast: true
                cached: true
                color: Theme.palette.dropShadow2
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            StatusListView {
                id: walletAccountsListView
                objectName: "walletAccountsListView"
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: parent.height - footer.height

                spacing: Style.current.smallPadding
                currentIndex: -1
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: height
                bottomMargin: Style.current.padding

                readonly property Item firstItem: count > 0 ? itemAtIndex(0) : null
                readonly property bool footerOverlayed: d.loaded && contentHeight > availableHeight

                delegate: StatusListItem {
                    objectName: "walletAccount-" + model.name
                    readonly property bool itemLoaded: !model.assetsLoading // needed for e2e tests
                    width: ListView.view.width - Style.current.padding * 2
                    highlighted: root.currentAddress.toLowerCase() === model.address.toLowerCase()
                    onHighlightedChanged: {
                        if (highlighted)
                            ListView.view.currentIndex = index
                    }
                    anchors.horizontalCenter: !!parent ? parent.horizontalCenter : undefined
                    title: model.name
                    subTitle: !model.hideFromTotalBalance ? LocaleUtils.currencyAmountToLocaleString(model.currencyBalance): ""
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
                            walletAccountContextMenu.active = true
                            walletAccountContextMenu.item.account = model
                            walletAccountContextMenu.item.popup(this, mouse.x, mouse.y)
                            return
                        }
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
                }

                header: Button {
                    id: header
                    verticalPadding: Style.current.padding
                    horizontalPadding: Style.current.padding
                    highlighted: root.showAllAccounts
                    objectName: "allAccountsBtn"

                    leftInset: Style.current.padding
                    bottomInset: Style.current.padding
                    leftPadding: Style.current.xlPadding
                    bottomPadding: Style.current.bigPadding

                    background: Rectangle {
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectAllAccounts()
                            hoverEnabled: true
                        }
                        radius: Style.current.radius
                        color: header.highlighted || mouseArea.containsMouse ? Style.current.backgroundHover : root.color
                        implicitWidth: parent.ListView.view.width - Style.current.padding * 2
                    }

                    contentItem: ColumnLayout {
                        spacing: 0
                        StatusBaseText {
                            id: allAccounts
                            color: Theme.palette.baseColor1
                            text: qsTr("All accounts")
                            font.weight: Font.Medium
                            font.pixelSize: 15
                            lineHeightMode: Text.FixedHeight
                            lineHeight: 22
                        }
                        RowLayout {
                            spacing: 4
                            StatusTextWithLoadingState {
                                id: walletAmountValue
                                objectName: "walletLeftListAmountValue"
                                customColor: Style.current.textColor
                                text: LocaleUtils.currencyAmountToLocaleString(RootStore.totalCurrencyBalance, {noSymbol: true})
                                font.pixelSize: 22
                                loading: RootStore.assetsLoading
                                lineHeightMode: Text.FixedHeight
                                lineHeight: 36
                                verticalAlignment: Text.AlignVCenter
                            }
                            StatusTextWithLoadingState {
                                customColor: Style.current.textColor
                                text: RootStore.totalCurrencyBalance.symbol
                                font.pixelSize: 13
                                loading: RootStore.assetsLoading
                                font.weight: Font.Medium
                                lineHeightMode: Text.FixedHeight
                                lineHeight: 22
                                verticalAlignment: Text.AlignBottom
                            }
                            visible: !networkConnectionStore.accountBalanceNotAvailable
                        }
                        StatusFlatRoundButton {
                            id: errorIcon
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
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

                model: SortFilterProxyModel {
                    sourceModel: RootStore.accounts
                    sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
                }
            }

            Control {
                id: footer

                anchors {
                    top: parent.top
                    // Bottom Margin is not applied to ListView if it's fully visible
                    topMargin: Math.min(walletAccountsListView.contentHeight, parent.height - height) + (walletAccountsListView.footerOverlayed ? 0 : walletAccountsListView.bottomMargin)
                    left: parent.left
                    right: parent.right
                }

                horizontalPadding: Style.current.padding
                verticalPadding: Style.current.padding

                background: Rectangle {
                    id: footerBackground
                    color: root.color
                    implicitWidth: root.width
                    implicitHeight: walletAccountsListView.firstItem.height + Style.current.xlPadding

                    layer.enabled: walletAccountsListView.footerOverlayed && !walletAccountsListView.atYEnd
                    layer.effect: DropShadow {
                        verticalOffset: -10
                        radius: 20
                        samples: 41
                        fast: true
                        cached: true
                        color: Theme.palette.dropShadow2
                    }

                    Separator {
                        anchors.top: parent.top
                        anchors.topMargin: -1
                        width: parent.width
                    }
                }

                contentItem: StatusFlatButton {
                    objectName: "savedAddressesBtn"
                    highlighted: root.showSavedAddresses
                    hoverColor: Style.current.backgroundHover
                    asset.bgColor: Theme.palette.primaryColor3
                    text: qsTr("Saved addresses")
                    icon.name: "address"
                    icon.width: 40
                    icon.height: 40
                    icon.color: Theme.palette.primaryColor1
                    isRoundIcon: true
                    textColor: Theme.palette.directColor1
                    textFillWidth: true
                    spacing: walletAccountsListView.firstItem.statusListItemTitleArea.anchors.leftMargin
                    onClicked: root.showSavedAddresses = true

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        propagateComposedEvents: true
                        onClicked: mouse.accepted = true
                    }
                }
            }
        }

    }
}
