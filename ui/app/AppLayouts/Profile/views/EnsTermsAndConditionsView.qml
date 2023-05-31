import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import utils 1.0

import shared.popups 1.0
import shared.status 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root

    property var ensUsernamesStore
    property var contactsStore
    property var stickersStore
    property string username: ""

    signal backBtnClicked();
    signal usernameRegistered(userName: string);

    StatusBaseText {
        id: sectionTitle
        text: qsTr("ENS usernames")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
        color: Theme.palette.directColor1
    }

    Loader {
        id: transactionDialog
        function open() {
            this.active = true
            this.item.open()
        }
        function closed() {
            this.active = false // kill an opened instance
        }
        sourceComponent: SendModal {
            id: buyEnsModal
            interactive: false
            sendType: Constants.SendType.ENSRegister
            preSelectedRecipient: root.ensUsernamesStore.getEnsRegisteredAddress()
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(10)
            preSelectedAsset: store.getAsset(buyEnsModal.store.assets, JSON.parse(root.stickersStore.getStatusToken()).symbol)
            sendTransaction: function() {
                if(bestRoutes.length === 1) {
                    let path = bestRoutes[0]
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    let maxFeePerGas = path.gasFees.maxFeePerGasM
                    root.ensUsernamesStore.authenticateAndRegisterEns(
                                root.ensUsernamesStore.chainId,
                                username,
                                selectedAccount.address,
                                path.gasAmount,
                                eip1559Enabled ? "" : path.gasFees.gasPrice,
                                eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "",
                                eip1559Enabled ? maxFeePerGas: path.gasFees.gasPrice,
                                eip1559Enabled,
                                )
                }
            }
            Connections {
                target: root.ensUsernamesStore.ensUsernamesModule
                function onTransactionWasSent(txResult: string) {
                    try {
                        let response = JSON.parse(txResult)
                        if (!response.success) {
                            if (response.result.includes(Constants.walletSection.cancelledMessage)) {
                                return
                            }
                            buyEnsModal.sendingError.text = response.result
                            return buyEnsModal.sendingError.open()
                        }
                        for(var i=0; i<buyEnsModal.bestRoutes.length; i++) {
                            usernameRegistered(username)
                            let url =  "%1/%2".arg(buyEnsModal.store.getEtherscanLink(buyEnsModal.bestRoutes[i].fromNetwork.chainId)).arg(response.result)
                            Global.displayToastMessage(qsTr("Transaction pending..."),
                                                       qsTr("View on etherscan"),
                                                       "",
                                                       true,
                                                       Constants.ephemeralNotificationType.normal,
                                                       url)
                        }
                    } catch (e) {
                        console.error('Error parsing the response', e)
                    }
                }
            }
        }
    }

    // TODO: Replace with StatusModal
    ModalPopup {
        id: popup
        title: qsTr("Terms of name registration")

        StatusScrollView {
            id: scroll
            anchors.fill: parent
            contentWidth: availableWidth

            Column {
                spacing: Style.current.halfPadding
                width: scroll.availableWidth


                StatusBaseText {
                    text: qsTr("Funds are deposited for 1 year. Your SNT will be locked, but not spent.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("After 1 year, you can release the name and get your deposit back, or take no action to keep the name.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("If terms of the contract change — e.g. Status makes contract upgrades — user has the right to release the username regardless of time held.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("The contract controller cannot access your deposited funds. They can only be moved back to the address that sent them.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("Your address(es) will be publicly associated with your ENS name.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("Usernames are created as subdomain nodes of stateofus.eth and are subject to the ENS smart contract terms.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("You authorize the contract to transfer SNT on your behalf. This can only occur when you approve a transaction to authorize the transfer.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("These terms are guaranteed by the smart contract logic at addresses:")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.weight: Font.Bold
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("%1 (Status UsernameRegistrar).").arg(root.ensUsernamesStore.getEnsRegisteredAddress())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.monoFont.name
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("<a href='%1%2'>Look up on Etherscan</a>")
                    .arg(root.ensUsernamesStore.getEtherscanLink())
                    .arg(root.ensUsernamesStore.getEnsRegisteredAddress())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: Global.openLink(link)
                    color: Theme.palette.directColor1
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                StatusBaseText {
                    text: qsTr("%1 (ENS Registry).").arg(root.ensUsernamesStore.getEnsRegistry())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.monoFont.name
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: qsTr("<a href='%1%2'>Look up on Etherscan</a>")
                    .arg(root.ensUsernamesStore.getEtherscanLink())
                    .arg(root.ensUsernamesStore.getEnsRegistry())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: Global.openLink(link)
                    color: Theme.palette.directColor1
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

            }
        }
    }

    StatusScrollView {
        id: sview
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: startBtn.top
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right

        contentWidth: availableWidth

        Item {
            id: contentItem
            width: sview.availableWidth

            Rectangle {
                id: circleAt
                anchors.top: parent.top
                anchors.topMargin: 24
                anchors.horizontalCenter: parent.horizontalCenter
                width: 60
                height: 60
                radius: 120
                color: Style.current.blue

                StatusBaseText {
                    text: "@"
                    opacity: 0.7
                    font.weight: Font.Bold
                    font.pixelSize: 18
                    color: Style.current.white
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            StatusBaseText {
                id: ensUsername
                text: username + ".stateofus.eth"
                font.weight: Font.Bold
                font.pixelSize: 18
                anchors.top: circleAt.bottom
                anchors.topMargin: 24
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.directColor1
            }

            StatusDescriptionListItem {
                id: walletAddressLbl
                title: qsTr("Wallet address")
                subTitle: root.ensUsernamesStore.getWalletDefaultAddress()
                tooltip.text: qsTr("Copied to clipboard!")
                asset.name: "copy"
                iconButton.onClicked: {
                    root.ensUsernamesStore.copyToClipboard(subTitle)
                    tooltip.visible = !tooltip.visible
                }
                anchors.top: ensUsername.bottom
                anchors.topMargin: 24
            }

            StatusDescriptionListItem {
                id: keyLbl
                title: qsTr("Key")
                subTitle: {
                    let pubKey = root.ensUsernamesStore.pubkey;
                    return pubKey.substring(0, 20) + "..." + pubKey.substring(pubKey.length - 20);
                }
                tooltip.text: qsTr("Copied to clipboard!")
                asset.name: "copy"
                iconButton.onClicked: {
                    root.ensUsernamesStore.copyToClipboard(root.ensUsernamesStore.pubkey)
                    tooltip.visible = !tooltip.visible
                }
                anchors.top: walletAddressLbl.bottom
                anchors.topMargin: 24
            }

            StatusCheckBox {
                id: termsAndConditionsCheckbox
                objectName: "ensAgreeTerms"
                anchors.top: keyLbl.bottom
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.leftMargin: 24
            }

            StatusBaseText {
                text: qsTr("Agree to <a href=\"#\">Terms of name registration.</a> I understand that my wallet address will be publicly connected to my username.")
                anchors.left: termsAndConditionsCheckbox.right
                anchors.leftMargin: Style.current.halfPadding
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                anchors.verticalCenter: termsAndConditionsCheckbox.verticalCenter
                onLinkActivated: popup.open()
                color: Theme.palette.directColor1
                TapHandler {
                    enabled: !parent.hoveredLink
                    onSingleTapped: termsAndConditionsCheckbox.toggle()
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }
    }

    StatusButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        text: qsTr("Back")
        onClicked: backBtnClicked()
    }

    Item {
        anchors.top: startBtn.top
        anchors.right: startBtn.left
        anchors.rightMargin: Style.current.padding
        width: childrenRect.width

        Image {
            id: image1
            height: 50
            width: height
            source: Style.png("tokens/SNT")
            sourceSize: Qt.size(width, height)
            cache: false
        }

        StatusBaseText {
            id: ensPriceLbl
            text: qsTr("10 SNT")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.top: image1.top
            color: Theme.palette.directColor1
            font.pixelSize: 14
        }

        StatusBaseText {
            text: qsTr("Deposit")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.top: ensPriceLbl.bottom
            color: Theme.palette.baseColor1
            font.pixelSize: 14
        }
    }

    StatusButton {
        id: startBtn
        objectName: "ensStartTransaction"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: parseFloat(root.ensUsernamesStore.getSntBalance()) < 10 ?
          qsTr("Not enough SNT") :
          qsTr("Register")
        enabled: parseFloat(root.ensUsernamesStore.getSntBalance()) >= 10 && termsAndConditionsCheckbox.checked
        onClicked: transactionDialog.open()
    }
}
