import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1

import utils 1.0

import shared.popups 1.0
import shared.controls 1.0
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property alias selectedAccount: accountSelector.selectedAccount
    id: popup

    //% "Receive"
    title: qsTrId("receive")
    height: 500
    width: 500


    Rectangle {
        id: qrCodeBox
        height: 240
        width: 240
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Style.current.radius
        border.width: 1
        border.color: Style.current.border

        Image {
            id: qrCodeImage
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height - Style.current.padding
            width: parent.width - Style.current.padding
            mipmap: true
            smooth: false
        }
    }

    StatusAccountSelector {
        id: accountSelector
        label: ""
        showAccountDetails: false
        accounts: RootStore.accounts
        currency: RootStore.currentCurrency
        anchors.top: qrCodeBox.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: 240
        dropdownWidth: parent.width - (Style.current.padding * 2)
        dropdownAlignment: Select.MenuAlignment.Center
        onSelectedAccountChanged: {
            if (selectedAccount.address) {
                qrCodeImage.source = RootStore.getQrCode(selectedAccount.address)
                txtWalletAddress.text = selectedAccount.address
            }
        }
    }

    Input {
	      id: txtWalletAddress
        //% "Wallet address"
        label: qsTrId("wallet-address")
        anchors.top: accountSelector.bottom
        anchors.topMargin: Style.current.padding
        copyToClipboard: true
        textField.readOnly: true
        customHeight: 56
    }

}

