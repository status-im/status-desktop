import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "../controls"
import "../popups"
import "../stores"

Rectangle {
    id: walletInfoContainer

    property var changeSelectedAccount: function(){}
    property var showSavedAddresses: function(showSavedAddresses){}
    property var emojiPopup: null

    function onAfterAddAccount () {
        walletInfoContainer.changeSelectedAccount(RootStore.accounts.rowCount() - 1)
    }

    color: Style.current.secondaryMenuBackground

    StyledText {
        id: title
        text: qsTr("Wallet")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
    }

    Item {
        id: walletValueTextContainer
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
        height: childrenRect.height

        StyledTextEdit {
            id: walletAmountValue
            color: Style.current.textColor
            text: {
                Utils.toLocaleString(parseFloat(RootStore.totalCurrencyBalance).toFixed(2), localAppSettings.locale, {"currency": true}) + " " + RootStore.currentCurrency.toUpperCase()
            }
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: parent.left
            font.weight: Font.Medium
            font.pixelSize: 30
        }

        StyledText {
            id: totalValue
            color: Style.current.secondaryText
            text: qsTr("Total value")
            anchors.left: walletAmountValue.left
            anchors.top: walletAmountValue.bottom
            font.weight: Font.Medium
            font.pixelSize: 13
        }
    }

    AddAccountModal {
        id: addAccountModal
        anchors.centerIn: parent
        onAfterAddAccount: walletInfoContainer.onAfterAddAccount()
        emojiPopup: walletInfoContainer.emojiPopup
    }

    StatusScrollView {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: btnSavedAddresses.height + Style.current.padding
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: 272
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        clip: true

        ListView {
            id: listView

            spacing: 5
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            delegate: StatusListItem {
                width: parent.width
                highlighted: RootStore.currentAccount.name === model.name
                title: model.name
                subTitle: Utils.toLocaleString(model.currencyBalance.toFixed(2), RootStore.locale, {"model.currency": true}) + " " + RootStore.currentCurrency.toUpperCase()
                icon.emoji: !!model.emoji ? model.emoji: ""
                icon.color: model.color
                icon.name: !model.emoji ? "filled-account": ""
                icon.letterSize: 14
                icon.isLetterIdenticon: !!model.emoji ? true : false
                icon.background.color: Theme.palette.primaryColor3
                onClicked: {
                    changeSelectedAccount(index)
                    showSavedAddresses(false)
                }
            }

            footer: Item {
                width: parent.width
                height: addAccountBtn.height + Style.current.xlPadding
                StatusButton {
                    id: addAccountBtn
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: Style.current.bigPadding
                    text: qsTr("Add account")
                    onClicked: addAccountModal.open()
                }
            }

            model: RootStore.accounts
//            model: RootStore.exampleWalletModel
        }
    }

    StatusNavigationListItem {
        id: btnSavedAddresses

        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding

        title: qsTr("Saved addresses")
        icon.name: "address"
        onClicked: {
            showSavedAddresses(true)
        }
    }
}
