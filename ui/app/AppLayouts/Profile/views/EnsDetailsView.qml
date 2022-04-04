import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1

import utils 1.0
import shared.status 1.0

Item {
    id: root
    property var ensUsernamesStore
    property var contactsStore
    property string username: ""
    property string walletAddress: "-"
    property string key: "-"
    property var expiration: 0

    signal backBtnClicked();
    signal usernameReleased(username: string);

    StatusBaseText {
        id: sectionTitle
        text: username
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
        color: Theme.palette.directColor1
    }

    Component {
        id: loadingImageComponent
        StatusLoadingIndicator {}
    }

    Loader {
        id: loadingImg
        active: false
        sourceComponent: loadingImageComponent
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.currentPadding
    }

    Connections {
        target: root.ensUsernamesStore.ensUsernamesModule
        onDetailsObtained: {
            if(username != ensName)
                return;
            walletAddressLbl.subTitle = address;
            keyLbl.subTitle = pubkey.substring(0, 20) + "..." + pubkey.substring(pubkey.length - 20);
            walletAddressLbl.visible = true;
            keyLbl.visible = true;
            releaseBtn.visible = isStatus
            releaseBtn.enabled = (Date.now() / 1000) > expirationTime && expirationTime > 0 &&
                    root.ensUsernamesStore.preferredUsername != username
            expiration = new Date(expirationTime * 1000).getTime()
        }
        onLoading: {
            loadingImg.active = isLoading
            if(!isLoading) return;
            walletAddressLbl.visible = false;
            keyLbl.visible = false;
            releaseBtn.visible = false;
            expiration = 0;
        }
    }

    StatusDescriptionListItem {
        id: walletAddressLbl
        title: qsTr("Wallet address")
        visible: false
        anchors.top: sectionTitle.bottom
        anchors.topMargin: 24
        icon.name: "copy"
        tooltip.text: qsTr("Copied to clipboard!")
        iconButton.onClicked: {
            root.ensUsernamesStore.copyToClipboard(subTitle)
            tooltip.visible = !tooltip.visible
        }
    }
    StatusDescriptionListItem {
        id: keyLbl
        title: qsTr("Key")
        visible: false
        anchors.top: walletAddressLbl.bottom
        anchors.topMargin: 24
        icon.name: "copy"
        tooltip.text: qsTr("Copied to clipboard!")
        iconButton.onClicked: {
            root.ensUsernamesStore.copyToClipboard(subTitle)
            tooltip.visible = !tooltip.visible
        }
    }

    Component {
        id: transactionDialogComponent
        StatusETHTransactionModal {
            ensUsernamesStore: root.ensUsernamesStore
            contactsStore: root.contactsStore
            ensUsername: root.username
            chainId: root.ensUsernamesStore.getChainIdForEns()
            title: qsTr("Connect username with your pubkey")
            onClosed: {
                destroy()
            }
            estimateGasFunction: function(selectedAccount) {
                if (username === "" || !selectedAccount) return 100000;
                return root.ensUsernamesStore.releaseEnsEstimate(Utils.removeStatusEns(username), selectedAccount.address)
            }
            onSendTransaction: function(selectedAddress, gasLimit, gasPrice, password) {
                return root.ensUsernamesStore.releaseEns(username,
                                              selectedAddress,
                                              gasLimit,
                                              gasPrice,
                                              password)
            }
            onSuccess: function(){
               usernameReleased(username);
            }

            width: 475
            height: 500
        }
    }

    StatusQControls.StatusButton {
        id: releaseBtn
        visible: false
        enabled: false
        anchors.top: keyLbl.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: qsTr("Release username")
        onClicked: {
            Global.openPopup(transactionDialogComponent)
        }
    }

    Text {
        visible: releaseBtn.visible && !releaseBtn.enabled
        anchors.top: releaseBtn.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: qsTr("Username locked. You won't be able to release it until %1").arg(Utils.formatShortDateStr(new Date(expiration).toDateString()))
        color: Style.current.darkGrey
    }


    StatusQControls.StatusButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Back")
        onClicked: backBtnClicked()
    }
}
