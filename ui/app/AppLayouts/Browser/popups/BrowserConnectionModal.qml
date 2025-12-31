import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Popups
import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared.panels
import shared.controls

import AppLayouts.stores.Browser as BrowserStores

import "../controls"

// TODO: replace with StatusDialog
StatusModal {
    id: root

    required property BrowserStores.BrowserRootStore browserRootStore
    required property BrowserStores.BrowserWalletStore browserWalletStore

    property var request: ({"hostname": "", "address": "", "title": "", "permission": ""})
    property string currentAddress: ""
    property bool interactedWith: false

    width: 360
    height: 480
    showHeader: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    topPadding: 0
    bottomPadding: 0

    function postMessage(isAllowed){
        console.log(isAllowed)
        interactedWith = true
        if(isAllowed){
            dappPermissionsModule.addPermission(request.hostname, request.address, request.permission)
        }
        // TODO: Will be handled by connector in next PR
    }

    onClosed: {
        if(!interactedWith){
            postMessage(false);
        }
    }

    contentItem: Item {
        width: parent.width
        height: parent.height

        ColumnLayout {
            spacing: Theme.bigPadding
            anchors.centerIn: parent

            RowLayout {
                property int imgSize: 40

                id: logoHeader
                spacing: Theme.halfPadding
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                FaviconImage {
                    id: siteImg
                }

                StatusIcon {
                    icon: "dots-icon"
                }

                RoundedIcon {
                    source: Assets.svg("check")
                    iconColor: Theme.palette.primaryColor1
                    color: Theme.palette.secondaryBackground
                }

                StatusIcon {
                    icon: "dots-icon"
                }

                RoundedIcon {
                    source: Assets.svg("walletIcon")
                    iconHeight: 18
                    iconWidth: 18
                    iconColor: accountSelector.currentAccount.iconColor || Theme.palette.primaryColor1
                    color: Theme.palette.background
                    border.width: 1
                    border.color: Theme.palette.border
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
                Layout.maximumWidth: root.width - Theme.padding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                color: Theme.palette.directColor1
            }

            AccountSelector {
                id: accountSelector
                implicitWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                model: root.browserWalletStore.accounts
                selectedAddress: root.browserWalletStore.dappBrowserAccount.address
                onCurrentAccountAddressChanged: {
                    if (!root.currentAddress) {
                        // We just set the account for the first time. Nothing to do here
                        root.currentAddress = currentAccountAddress
                        return
                    }
                    if (root.currentAddress === currentAccountAddress) {
                        return
                    }

                    root.currentAddress = currentAccountAddress

                    if (currentAccountAddress) {
                        root.browserWalletStore.switchAccountByAddress(currentAccountAddress)
                    }
                }
            }

            StatusBaseText {
                id: infoText
                text: {
                    switch(request.permission){
                    case Constants.permission_web3: return qsTr("Allowing authorizes this DApp to retrieve your wallet address and enable Web3");
                    case Constants.permission_contactCode: return qsTr("Granting access authorizes this DApp to retrieve your chat key");
                    default: return qsTr("Unknown permission: %1").arg(request.permission);
                    }
                }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.baseColor1
                Layout.maximumWidth: root.width - Theme.padding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            }

            Row {
                spacing: Theme.padding
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                StatusButton {
                    type: StatusBaseButton.Type.Danger
                    width: 151
                    text: qsTr("Deny")
                    onClicked: {
                        postMessage(false);
                        root.close();
                    }
                }

                StatusButton {
                    type: StatusBaseButton.Type.Success
                    width: 151
                    text: qsTr("Allow")
                    onClicked: {
                        postMessage(true);
                        root.close();
                    }
                }
            }
        }
    }
}
