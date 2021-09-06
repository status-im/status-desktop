import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Item {
    property var currentAccount: walletModel.accountsView.currentAccount
    property var changeSelectedAccount

    function sendTransaction(sender, recipient, gasLimit, gasPrice, selectedAmount, selectedAsset, password, uuid) {
        let success = false
        if (selectedAsset.address == ""){
            success = walletModel.transactionsView.transferEth(
                                                 sender.address,
                                                 recipient.address,
                                                 selectedAmount,
                                                 gasLimit,
                                                 gasPrice,
                                                 password,
                                                 uuid)
        } else {
            success = walletModel.transactionsView.transferTokens(
                                                 sender.address,
                                                 recipient.address,
                                                 selectedAsset.address,
                                                 selectedAmount,
                                                 gasLimit,
                                                 gasPrice,
                                                 password,
                                                 uuid)
        }

        if(!success){
            sendingError.text = qsTr("Invalid transaction parameters")
            sendingError.open()
        }
    }

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    Connections {
        target: walletModel.transactionsView
        onTransactionWasSent: {
            try {
                let response = JSON.parse(txResult)

                if (response.uuid !== signTransactionModal.uuid) return
                
                if (!response.success) {
                    if (Utils.isInvalidPasswordMessage(response.result)){
                        signTransactionModal.transactionSigner.validationError = qsTr("Wrong password")
                        return
                    }
                    sendingError.text = response.result
                    return sendingError.open()
                }

                toastMessage.title = qsTrId("Transaction pending")
                toastMessage.source = "../../img/loading.svg"
                toastMessage.iconColor = Theme.palette.primaryColor1
                toastMessage.iconRotates = true
                toastMessage.link = `${walletModel.utilsView.etherscanLink}/${response.result}`
                toastMessage.open()
                signTransactionModal.close()
                sendTransactionModal.close()
            } catch (e) {
                console.error('Error parsing the response', e)
            }
        }
        onTransactionCompleted: {
            if (success) {
                toastMessage.title = qsTrId("Transaction completed")
                toastMessage.source = "../../img/check-circle.svg"
                toastMessage.iconColor = Theme.palette.successColor1
            } else {
                toastMessage.title = qsTrId("Transaction failed")
                toastMessage.source = "../../img/block-icon.svg"
                toastMessage.iconColor = Theme.palette.dangerColor1
            }
            toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txHash}`
            toastMessage.open()
        }
    }

    id: walletHeader
    height: walletAddress.y + walletAddress.height
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    Row {
        id: accountRow
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.left: parent.left
        anchors.leftMargin: 24

        spacing: 8

        StyledText {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            text: currentAccount.name
            font.weight: Font.Medium
            font.pixelSize: 28
        }

        Rectangle {
            id: separatorDot
            width: 8
            height: 8
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            color: Style.current.primary
            radius: 50
        }

        StyledText {
            id: walletBalance
            anchors.verticalCenter: parent.verticalCenter
            text: currentAccount.balance.toUpperCase()
            font.pixelSize: 22
        }
    }

    MouseArea {
        anchors.fill: accountRow
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            openPopup(shareModalComponent);
        }
    }

    StatusExpandableAddress {
        id: walletAddress
        address: currentAccount.address
        anchors.top: accountRow.bottom
        anchors.left: accountRow.left
        addressWidth: 180
        anchors.leftMargin: 0
        anchors.topMargin: 0
    }

    Item {
        property int btnMargin: 8
        property int btnOuterMargin: Style.current.bigPadding
        id: walletMenu
        width: sendBtn.width + receiveBtn.width + settingsBtn.width
               + walletMenu.btnOuterMargin * 2
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16

        HeaderButton {
            id: sendBtn
            imageSource: "../../img/send.svg"
            //% "Send"
            text: qsTrId("command-button-send")
            onClicked: function () {
                accountSelectorModal.open()
            }
        }

        HeaderButton {
            id: receiveBtn
            imageSource: "../../img/send.svg"
            flipImage: true
            //% "Receive"
            text: qsTrId("receive")
            onClicked: () => console.log("TODO")
            anchors.left: sendBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin
        }

        HeaderButton {
            id: settingsBtn
            imageSource: "../../img/settings.svg"
            flipImage: true
            text: ""
            onClicked: function () {
                if (newSettingsMenu.opened) {
                    newSettingsMenu.close()
                } else {
                    let x = settingsBtn.x + settingsBtn.width / 2 - newSettingsMenu.width / 2
                    newSettingsMenu.popup(x, settingsBtn.height)
                }
            }
            anchors.left: receiveBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin

            PopupMenu {
                id: newSettingsMenu
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                width: 176
                Action {
                    //% "Account Settings"
                    text: qsTrId("account-settings")
                    icon.source: "../../img/manage-wallet.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: console.log("TODO")
                }
                Action {
                    //% "Manage Assets"
                    text: qsTrId("manage-assets")
                    icon.source: "../../img/add_remove_token.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: console.log("TODO")
                }
                Action {
                    //% "Set Currency"
                    text: qsTrId("set-currency")
                    icon.source: "../../img/currency.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: console.log("TODO")
                }
            }
        }
    }

    Component {
        id: shareModalComponent
        ShareModal {
            onClosed: {
                destroy();
            }
        }
    }

    StatusModal {
        id: accountSelectorModal
        anchors.centerIn: parent
        width: 300
        header.title: qsTr("Select account")

        contentItem: Column {
            width: accountSelectorModal.width

            Item { width: parent.width; height: 12 }

            Repeater {
                model: walletModel.accountsView.accounts
                delegate: StatusListItem {
                    width: accountSelectorModal.width - 24
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon.name: "filled-account"
                    icon.width: 24
                    icon.height: 24
                    icon.color: model.iconColor
                    title: model.name
                    subTitle: model.balance.toUpperCase()
                    visible: model.walletType !== Constants.watchWalletType
                    sensor.onClicked: {
                        sendTransactionModal.sender = model
                        sendTransactionModal.open()
                        accountSelectorModal.close()
                    }
                }
            }
        }
    }


    StatusModal {
        id: sendTransactionModal
        anchors.centerIn: parent
        width: 918

        property var sender
        property var recipient

        property var reset: function () {
            sender = null
            recipient = null
        }

        onClosed: {
            reset()
        }

        header.title: sender ? sender.name : ""
        contentItem: Item {

            width: sendTransactionModal.width
            implicitHeight: childrenRect.height + 24

            property alias recipientInput: recipientInput
            property alias selectedRecipient: selectedRecipientLoader.selectedRecipient

            ButtonGroup {
                id: tabBarGroup
            }

            StatusSwitchTabBar {
                id: switchTabBar
                anchors.top: parent.top
                anchors.topMargin: 24
                anchors.horizontalCenter: parent.horizontalCenter

                StatusSwitchTabButton {
                    text: qsTr("Swap")
                    checked: false
                    ButtonGroup.group: tabBarGroup
                }
                StatusSwitchTabButton {
                    text: qsTr("Swap & Send")
                    checked: false
                    ButtonGroup.group: tabBarGroup
                }
                StatusSwitchTabButton {
                    text: qsTr("Send")
                    checked: true
                    ButtonGroup.group: tabBarGroup
                }
            }

            Row {
                id: content
                anchors.top: switchTabBar.bottom
                anchors.topMargin: 24
                width: sendTransactionModal.width - 48
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 0

                Column {
                    width: 435
                    spacing: 0

                    AssetAndAmountInput {
                        id: assetAndAmount
                        selectedAccount: currentAccount
                        defaultCurrency: walletModel.balanceView.defaultCurrency
                        getFiatValue: walletModel.balanceView.getFiatValue
                        getCryptoValue: walletModel.balanceView.getCryptoValue
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 36
                        onSelectedAssetChanged: if (isValid && gasSelector.visible) { gasSelector.estimateGas() }
                        onSelectedAmountChanged: if (isValid && gasSelector.visible) { gasSelector.estimateGas() }
                        txtFiatBalance.visible: false
                        txtFiatSymbol.visible: false
                    }

                    StatusBaseInput {
                        id: fiatBalanceInput
                        implicitHeight: 56
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 36

                        topPadding: 18
                        text: assetAndAmount.selectedFiatAmount
                        color: !focussed ? Theme.palette.baseColor1: Theme.palette.directColor1
                        Keys.onReleased: {
                            let balance = text.trim()
                            if (balance === "" || isNaN(balance)) {
                                return
                            }
                            assetAndAmount.selectedAmount = walletModel.balanceView.getCryptoValue(balance, walletModel.balanceView.defaultCurrency, assetAndAmount.selectedAsset.symbol)
                        }

                        StatusBaseText {
                            text: walletModel.balanceView.defaultCurrency.toUpperCase()
                            color: Theme.palette.baseColor1
                            font.pixelSize: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 293
                    color: Theme.palette.baseColor2
                }

                Item {
                    width: 435
                    height: childrenRect.height

                    StatusInput {
                        id: recipientInput

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 36

                        leftPadding: 0
                        rightPadding: 0

                        label: qsTr("To")
                        input.placeholderText: qsTr("Enter an ENS name or address")
                        input.implicitHeight: 56
                        input.component: StatusLoadingIndicator {
                            visible: recipientInput.pending
                            width: 14
                        }
                        validators: [StatusAddressOrEnsValidator {}]
                        asyncValidators: [
                            StatusEnsValidator {
                                onEnsResolved: {
                                    if (!!address) {
                                        sendTransactionModal.recipient = {
                                            address: text
                                        }
                                    }
                                }
                            }
                        ]
                    }

                    Loader {
                        id: selectedRecipientLoader
                        anchors.top: parent.top
                        anchors.topMargin: 18
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.right: parent.right
                        active: !!selectedRecipient
                        property var selectedRecipient
                        
                        sourceComponent: StatusListItem {
                            sensor.enabled: false
                            anchors.left: parent.left
                            anchors.right: parent.right
                            statusListItemTitle.font.weight: Font.Medium
                            icon.name: "filled-account"
                            icon.width: 24
                            icon.height: 24
                            icon.color: selectedRecipientLoader.selectedRecipient.iconColor
                            icon.background.color: "transparent"
                            icon.background.width: 20
                            title: selectedRecipientLoader.selectedRecipient.name
                            subTitle: Utils.compactAddress(selectedRecipientLoader.selectedRecipient.address, 4)
                            rightPadding: 0
                            components: [
                                StatusFlatRoundButton {
                                    type: StatusFlatRoundButton.Type.Secondary
                                    width: 32
                                    height: 32
                                    icon.name: "close"
                                    icon.width: 20
                                    icon.height: 20
                                    icon.color: Theme.palette.baseColor1
                                    onClicked: {
                                        sendTransactionModal.recipient = selectedRecipientLoader.selectedRecipient = null
                                    }
                                }
                            ]
                        }
                    }

                    Item {
                        id: accountSelectArea
                        width: parent.width
                        height: childrenRect.height
                        anchors.top: recipientInput.bottom
                        anchors.topMargin: 24
                        visible: !selectedRecipientLoader.selectedRecipient && !gasSelector.visible

                        TabBar {
                            id: tabbar
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 24

                            StatusTabButton {
                                btnText: qsTr("My Accounts")
                            }
                        }

                        ScrollView {
                            anchors.top: tabbar.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 36
                            anchors.right: parent.right
                            contentHeight: accountsList.height
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            height: 250
                            clip: true
                  
                            ListView {
                                anchors.fill: parent
                                id: accountsList
                                model: walletModel.accountsView.accounts
                                delegate: StatusListItem {
                                    icon.name: "filled-account"
                                    icon.color: model.iconColor
                                    icon.width: 24
                                    icon.height: 24
                                    icon.background.color: "transparent"
                                    icon.background.width: 20
                                    title: model.name
                                    statusListItemTitle.font.weight: Font.Medium
                                    subTitle: Utils.compactAddress(model.address, 4)
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    sensor.onClicked: {
                                        sendTransactionModal.recipient = selectedRecipientLoader.selectedRecipient = model
                                        recipientInput.reset()
                                    }
                                }
                            }
                        }
                    }

                    GasSelector {
                        id: gasSelector
                        visible: (!!selectedRecipientLoader.selectedRecipient || (!!recipientInput.text && recipientInput.valid) && !recipientInput.pending)
                        anchors.top: recipientInput.bottom
                        anchors.topMargin: 16
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 36
                        onVisibleChanged: {
                            if (visible && assetAndAmount.isValid) {
                                estimateGas()
                            }
                        }

                        getGasEthValue: walletModel.gasView.getGasEthValue
                        getFiatValue: walletModel.balanceView.getFiatValue
                        defaultCurrency: walletModel.balanceView.defaultCurrency
                        property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                            if (!sendTransactionModal.recipient && assetAndAmount.selectedAsset && assetAndAmount.selectedAsset.address &&
                                assetAndAmount.selectedAmount) return
                            
                            let gasEstimate = JSON.parse(walletModel.gasView.estimateGas(
                                currentAccount.address,
                                sendTransactionModal.recipient.address,
                                assetAndAmount.selectedAsset.address,
                                assetAndAmount.selectedAmount,
                                ""))

                            if (!gasEstimate.success) {
                                console.warn(qsTrId("Error estimating gas: %1").arg(gasEstimate.error.message))
                                return
                            }
                            selectedGasLimit = gasEstimate.result
                        })
                        gasSelectorButtonWidth: 125
                        gasSelectorButtonHeight: 115
                    }
                }
            }

            GasValidatorV2 {
                id: gasValidator
                anchors.top: content.bottom
                anchors.topMargin: 24
                width: parent.width
                visible: gasSelector.visible && !isValid
                height: visible ? implicitHeight: 0
                selectedAccount: sendTransactionModal.sender
                selectedAmount: parseFloat(assetAndAmount.selectedAmount)
                selectedAsset: assetAndAmount.selectedAsset
                selectedGasEthValue: gasSelector.selectedGasEthValue
            }

            Rectangle {
                height: 32
                width: 32
                anchors.top: content.top
                anchors.topMargin: 37
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.palette.statusModal.backgroundColor

                StatusIcon {
                    icon: "arrow-right"
                    color: Theme.palette.directColor1
                    width: 17.5
                    anchors.centerIn: parent
                }
            }
        }
        rightButtons: [
            StatusButton {
                text: qsTr("Sign")
                enabled: !!sendTransactionModal.sender && 
                         !!sendTransactionModal.recipient &&
                         assetAndAmount.isValid && 
                         gasValidator.isValid
                onClicked: {
                    signTransactionModal.sender = sendTransactionModal.sender
                    signTransactionModal.recipient = sendTransactionModal.recipient
                    signTransactionModal.selectedAmount = assetAndAmount.selectedAmount
                    signTransactionModal.selectedAsset = assetAndAmount.selectedAsset
                    signTransactionModal.gasLimit = gasSelector.selectedGasLimit
                    signTransactionModal.gasPrice = gasSelector.selectedGasPrice
                    signTransactionModal.open()
                }
            }
        ]
    }

    StatusModal {
        id: signTransactionModal
        anchors.centerIn: parent

        header.title: qsTr("Sign transaction")
        onClosed: {
            reset()
        }

        property alias transactionSigner: transactionSigner
        readonly property string uuid: Utils.uuid()
        property var sender
        property var recipient
        property string gasLimit: ""
        property string gasPrice: ""
        property var selectedAsset
        property string selectedAmount: ""

        property var reset: function () {
            sender = null
            recipient = null
            gasLimit = ""
            gasPrice = ""
            selectedAsset = null
            selectedAmount = ""
        }

        contentItem: Item {
            implicitHeight: transactionSigner.height + 48
            width: signTransactionModal.width

            TransactionSigner {
                id: transactionSigner
                width: parent.width - 32
                signingPhrase: walletModel.utilsView.signingPhrase
                anchors.centerIn: parent
            }
        }
        rightButtons: [
            StatusButton {
                text: qsTr("Send")
                enabled: !!signTransactionModal.sender &&
                         !!signTransactionModal.recipient &&
                         !!signTransactionModal.gasLimit &&
                         !!signTransactionModal.gasPrice &&
                         !!signTransactionModal.selectedAmount &&
                         !!signTransactionModal.selectedAsset &&
                         transactionSigner.isValid
                onClicked: sendTransaction(
                    signTransactionModal.sender, 
                    signTransactionModal.recipient, 
                    signTransactionModal.gasLimit, 
                    signTransactionModal.gasPrice, 
                    signTransactionModal.selectedAmount, 
                    signTransactionModal.selectedAsset, 
                    transactionSigner.enteredPassword,
                    signTransactionModal.uuid
                )
            }
        ]
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
