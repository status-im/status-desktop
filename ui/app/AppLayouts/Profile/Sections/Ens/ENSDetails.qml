import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status/core"
import "../../../../../shared/status"

Item {
    property string username: ""
    property string walletAddress: "-"
    property string key: "-"
    property var expiration: 0

    signal backBtnClicked();
    signal usernameReleased(username: string);

    StyledText {
        id: sectionTitle
        text: username
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
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
        target: profileModel.ens
        onDetailsObtained: {
            if(username != ensName) return;
                walletAddressLbl.text = address;
                walletAddressLbl.textToCopy = address;
                keyLbl.text = pubkey.substring(0, 20) + "..." + pubkey.substring(pubkey.length - 20);
                keyLbl.textToCopy = pubkey;
                walletAddressLbl.visible = true;
                keyLbl.visible = true;
                releaseBtn.visible = isStatus
                releaseBtn.enabled = (Date.now() / 1000) > expirationTime && expirationTime > 0 && profileModel.ens.preferredUsername != username
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

    TextWithLabel {
        id: walletAddressLbl
        //% "Wallet address"
        label: qsTrId("wallet-address")
        visible: false
        text:  ""
        textToCopy: ""
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: sectionTitle.bottom
        anchors.topMargin: 24
    }

    TextWithLabel {
        id: keyLbl
        visible: false
        //% "Key"
        label: qsTrId("key")
        text: ""
        textToCopy: ""
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: walletAddressLbl.bottom
        anchors.topMargin: 24
    }

    Component {
        id: transactionDialogComponent
        StatusETHTransactionModal {
            onOpened: {
                walletModel.gasView.getGasPricePredictions()
            }
            title: qsTr("Connect username with your pubkey")
            onClosed: {
                destroy()
            }
            estimateGasFunction: function(selectedAccount) {
                if (username === "" || !selectedAccount) return 100000;
                return profileModel.ens.releaseEstimate(Utils.removeStatusEns(username), selectedAccount.address)
            }
            onSendTransaction: function(selectedAddress, gasLimit, gasPrice, password) {
                return profileModel.ens.release(username,
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

    StatusButton {
        id: releaseBtn
        visible: false
        enabled: false
        anchors.top: keyLbl.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: qsTrId("Release username")
        onClicked: {
            openPopup(transactionDialogComponent)
        }
    }

    Text {
        visible: releaseBtn.visible && !releaseBtn.enabled
        anchors.top: releaseBtn.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: qsTr("Username locked. You won’t be able to release it until %1").arg(Utils.formatShortDateStr(new Date(expiration).toDateString()))
        color: Style.current.darkGrey
    }


    StatusButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Back"
        text: qsTrId("back")
        onClicked: backBtnClicked()
    }
}
