import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0

import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property alias selectedAccount: accountSelector.selectedAccount

    //% "Receive"
    header.title: qsTrId("receive")
    contentHeight: layout.implicitHeight
    width: 556

    contentItem: Column {
        id: layout
        width: popup.width

        topPadding: Style.current.smallPadding
        spacing: Style.current.bigPadding

        Rectangle {
            id: qrCodeBox
            anchors.horizontalCenter: parent.horizontalCenter
            height: 339
            width: 339
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: qrCodeBox.width
                    height: qrCodeBox.height
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: qrCodeBox.width
                        height: qrCodeBox.height
                        radius: Style.current.bigPadding
                        border.width: 1
                        border.color: Style.current.border
                    }
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        width: Style.current.bigPadding
                        height: Style.current.bigPadding
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: Style.current.bigPadding
                        height: Style.current.bigPadding
                    }
                }
            }

            Image {
                id: qrCodeImage
                anchors.centerIn: parent
                height: parent.height
                width: parent.width
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: false
            }

            Rectangle {
                anchors.centerIn: qrCodeImage
                width: 78
                height: 78
                color: "white"
                StatusIcon {
                    anchors.centerIn: parent
                    anchors.margins: 2
                    width: 78
                    height: 78
                    source: Style.svg("status-logo-icon")
                }
            }
        }

        StatusAccountSelector {
            id: accountSelector
            anchors.horizontalCenter: parent.horizontalCenter
            width: 240
            label: ""
            showAccountDetails: false
            accounts: RootStore.accounts
            currency: RootStore.currentCurrency
            dropdownWidth: parent.width - (Style.current.padding * 2)
            dropdownAlignment: StatusSelect.MenuAlignment.Center
            onSelectedAccountChanged: {
                if (selectedAccount.address) {
                    qrCodeImage.source = RootStore.getQrCode(selectedAccount.address)
                    txtWalletAddress.text = selectedAccount.address
                }
            }
        }

        Item  {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: addressLabel.height + copyButton.height
            Column {
                id: addressLabel
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Style.current.bigPadding
                StatusBaseText {
                    id: contactsLabel
                    font.pixelSize: 15
                    color: Theme.palette.baseColor1
                    text: qsTr("Your Address")
                }
                StatusAddress {
                    id: txtWalletAddress
                    color: Theme.palette.directColor1
                    font.pixelSize: 15
                }
            }
            Column {
                id: copyButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.bigPadding
                spacing: 5
                CopyToClipBoardButton {
                    store: RootStore
                    textToCopy: txtWalletAddress.text
                }
                StatusBaseText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 13
                    color: Theme.palette.primaryColor1
                    text: qsTr("Copy")
                }
            }
        }
    }
}

