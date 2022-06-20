import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"
import "../stores"

StatusModal {
    id: browserConnectionModal

    property var currentTab
    property var request: ({"hostname": "", "address": "", "title": "", "permission": ""})
    property string currentAddress: ""
    property bool interactedWith: false
    property var web3Response: function(){}

    width: Style.dp(360)
    height: Style.dp(480)
    showHeader: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    topPadding: 0
    bottomPadding: 0

    function postMessage(isAllowed){
        console.log(isAllowed)
        interactedWith = true
        RootStore.currentTabConnected = isAllowed
        if(isAllowed){
            Web3ProviderStore.addPermission(request.hostname, request.address, request.permission)
        }
        Web3ProviderStore.web3ProviderInst.postMessage("", Constants.api_request, JSON.stringify(request))
    }

    onClosed: {
        if(!interactedWith){
            RootStore.currentTabConnected = false
            postMessage(false);
        }
    }

    contentItem: Item {
        width: parent.width
        height: parent.height

        ColumnLayout {
            spacing: Style.current.bigPadding
            anchors.centerIn: parent

            RowLayout {
                property int imgSize: Style.dp(40)

                id: logoHeader
                spacing: Style.current.halfPadding
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                FaviconImage {
                    id: siteImg
                }

                SVGImage {
                    id: dots1
                    source: Style.svg("dots-icon")
                }

                RoundedIcon {
                    source: Style.svg("check")
                    iconColor: Style.current.primary
                    color: Style.current.secondaryBackground
                }

                SVGImage {
                    id: dots2
                    source: Style.svg("dots-icon")
                }

                RoundedIcon {
                    source: Style.svg("walletIcon")
                    iconHeight: Style.dp(18)
                    iconWidth: Style.dp(18)
                    iconColor: accountSelector.selectedAccount.iconColor || Style.current.primary
                    color: Style.current.background
                    border.width: Style.dp(1)
                    border.color: Style.current.border
                }
            }

            StatusBaseText {
                id: titleText
                //% "'%1' would like to connect to"
                text: qsTrId("--1--would-like-to-connect-to").arg(request.title)
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: Style.dp(17)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                Layout.maximumWidth: browserConnectionModal.width - Style.current.padding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                color: Theme.palette.directColor1
            }

            StatusAccountSelector {
                id: accountSelector
                label: ""
                implicitWidth: Style.dp(300)
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                showAccountDetails: false
                accounts: WalletStore.accounts
                selectedAccount: WalletStore.dappBrowserAccount
                currency: WalletStore.defaultCurrency
                onSelectedAccountChanged: {
                    if (!browserConnectionModal.currentAddress) {
                        // We just set the account for the first time. Nothing to do here
                        browserConnectionModal.currentAddress = selectedAccount.address
                        return
                    }
                    if (browserConnectionModal.currentAddress === selectedAccount.address) {
                        return
                    }

                    browserConnectionModal.currentAddress = selectedAccount.address
                    Web3ProviderStore.web3ProviderInst.dappsAddress = selectedAccount.address;

                    if (selectedAccount.address) {
                        Web3ProviderStore.web3ProviderInst.dappsAddress = selectedAccount.address;
                        WalletStore.switchAccountByAddress(selectedAccount.address)
                    }
                }
            }

            StatusBaseText {
                id: infoText
                text: {
                    switch(request.permission){
                        //% "Allowing authorizes this DApp to retrieve your wallet address and enable Web3"
                    case Constants.permission_web3: return qsTrId("allowing-authorizes-this-dapp");
                        //% "Granting access authorizes this DApp to retrieve your chat key"
                    case Constants.permission_contactCode: return qsTrId("your-contact-code");
                    default: return qsTr("Unknown permission: " + request.permission);
                    }
                }
                wrapMode: Text.WordWrap
                font.pixelSize: Style.dp(15)
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.baseColor1
                Layout.maximumWidth: browserConnectionModal.width - Style.current.padding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            }

            Row {
                spacing: Style.current.padding
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                StatusButton {
                    type: StatusBaseButton.Type.Danger
                    width: Style.dp(151)
                    //% "Deny"
                    text: qsTrId("deny")
                    onClicked: {
                        postMessage(false);
                        browserConnectionModal.close();
                    }
                }

                StatusButton {
                    normalColor: Utils.setColorAlpha(Style.current.success, 0.1)
                    textColor: Style.current.success
                    width: Style.dp(151)
                    //% "Allow"
                    text: qsTrId("allow")
                    onClicked: {
                        postMessage(true);
                        browserConnectionModal.close();
                    }
                }
            }
        }
    }
}
