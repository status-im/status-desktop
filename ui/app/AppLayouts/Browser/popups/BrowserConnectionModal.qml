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

    width: 360
    height: 480
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
                property int imgSize: 40

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
                    iconHeight: 18
                    iconWidth: 18
                    iconColor: accountSelector.selectedAccount.iconColor || Style.current.primary
                    color: Style.current.background
                    border.width: 1
                    border.color: Style.current.border
                }
            }

            StatusBaseText {
                id: titleText
                text: qsTr("'%1' would like to connect to").arg(request.title)
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 17
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
                implicitWidth: 300
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
                    case Constants.permission_web3: return qsTr("Allowing authorizes this DApp to retrieve your wallet address and enable Web3");
                    case Constants.permission_contactCode: return qsTr("Granting access authorizes this DApp to retrieve your chat key");
                    default: return qsTr("Unknown permission: " + request.permission);
                    }
                }
                wrapMode: Text.WordWrap
                font.pixelSize: 15
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
                    width: 151
                    text: qsTr("Deny")
                    onClicked: {
                        postMessage(false);
                        browserConnectionModal.close();
                    }
                }

                StatusButton {
                    normalColor: Utils.setColorAlpha(Style.current.success, 0.1)
                    textColor: Style.current.success
                    width: 151
                    text: qsTr("Allow")
                    onClicked: {
                        postMessage(true);
                        browserConnectionModal.close();
                    }
                }
            }
        }
    }
}
