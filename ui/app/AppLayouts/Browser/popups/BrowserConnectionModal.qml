import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import utils 1.0

import StatusQ.Controls 0.1

import "../../../../shared"
import "../../../../shared/panels"
import "../../../../shared/controls"
import "../controls"
import "../stores"

// TODO: replace StatusModal
Popup {
    property var currentTab
    property var request: ({"hostname": "", "title": "", "permission": ""})
    property string currentAddress: ""
    property bool interactedWith: false

    id: root
    modal: true
    Overlay.modal: Rectangle {
        color: "#60000000"
    }
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: 360
    height: 480
    background: Rectangle {
        color: Style.current.background
        radius: 8
    }
    padding: 0

    function postMessage(isAllowed){
        interactedWith = true
        request.isAllowed = isAllowed;
        currentTabConnected = isAllowed
        provider.web3Response(Web3ProviderStore.web3ProviderInst.postMessage(JSON.stringify(request)));
    }

    onClosed: {
        if(!interactedWith){
            currentTabConnected = false
            postMessage(false);
        }
        root.destroy();
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        spacing: Style.current.bigPadding
        anchors.top: parent.top
        anchors.topMargin: 90

        RowLayout {
            property int imgSize: 40

            id: logoHeader
            spacing: Style.current.halfPadding
            width: 176
            height: imgSize
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

            FaviconImage {
                id: siteImg
                width: logoHeader.imgSize
                height: logoHeader.imgSize
            }

            SVGImage {
                id: dots1
                source: Style.svg("dots-icon")
                width: 20
                height: 4
            }

            RoundedIcon {
                source: Style.svg("check")
                iconColor: Style.current.primary
                color: Style.current.secondaryBackground
                width: 24
                height: 24
            }

            SVGImage {
                id: dots2
                source: Style.svg("dots-icon")
                width: 20
                height: 4
            }

            RoundedIcon {
                source: Style.svg("walletIcon")
                iconHeight: 18
                iconWidth: 18
                iconColor: accountSelector.selectedAccount.iconColor || Style.current.primary
                color: Style.current.background
                width: logoHeader.imgSize
                height: logoHeader.imgSize
                border.width: 1
                border.color: Style.current.border
            }
        }

        StyledText {
            id: titleText
            //% "'%1' would like to connect to"
            text: qsTrId("--1--would-like-to-connect-to").arg(request.title)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            wrapMode: Text.WordWrap
            font.weight: Font.Bold
            font.pixelSize: 17
            horizontalAlignment: Text.AlignHCenter
        }

        StatusAccountSelector {
            id: accountSelector
            label: ""
            width: 190
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            showAccountDetails: false
            accounts: WalletStore.accounts
            selectedAccount: WalletStore.dappBrowserAccount
            currency: WalletStore.defaultCurrency
            onSelectedAccountChanged: {
                if (!root.currentAddress) {
                    // We just set the account for the first time. Nothing to do here
                    root.currentAddress = selectedAccount.address
                    return
                }
                if (root.currentAddress === selectedAccount.address) {
                    return
                }

                root.currentAddress = selectedAccount.address
                Web3ProviderStore.web3ProviderInst.dappsAddress = selectedAccount.address;
                Web3ProviderStore.web3ProviderInst.clearPermissions();
                if (selectField.menu.currentIndex !== -1) {
                    Web3ProviderStore.web3ProviderInst.dappsAddress = selectedAccount.address;
                    WalletStore.setDappBrowserAddress()
                }
            }
        }


        StyledText {
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
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            color: Style.current.secondaryText
        }

        Row {
            width: childrenRect.width
            spacing: Style.current.padding
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

            StatusButton {
                type: StatusBaseButton.Type.Danger
                width: 155
                //% "Deny"
                text: qsTrId("deny")
                onClicked: {
                    postMessage(false);
                    root.close();
                }
            }

            StyledButton {
                btnColor: Utils.setColorAlpha(Style.current.success, 0.1)
                textColor: Style.current.success
                width: 155
                //% "Allow"
                label: qsTrId("allow")
                onClicked: {
                    postMessage(true);
                    root.close();
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
