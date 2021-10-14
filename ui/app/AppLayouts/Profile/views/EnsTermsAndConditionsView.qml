import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root
    property var store
    property string username: ""

    signal backBtnClicked();
    signal usernameRegistered(userName: string);

    StatusBaseText {
        id: sectionTitle
        //% "ENS usernames"
        text: qsTrId("ens-usernames")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
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
        sourceComponent: StatusSNTTransactionModal {
            assetPrice: "10"
            contractAddress: root.store.ensRegisterAddress
            estimateGasFunction: function(selectedAccount, uuid) {
                if (username === "" || !selectedAccount) return 380000;
                return root.store.registerEnsGasEstimate(username, selectedAccount.address)
            }
            onSendTransaction: function(selectedAddress, gasLimit, gasPrice, tipLimit, overallLimit, password) {
                return root.store.registerEns(username,
                                                    selectedAddress,
                                                    gasLimit,
                                                    tipLimit,
                                                    overallLimit,
                                                    gasPrice,
                                                    password)
            }
            onSuccess: function(){
                usernameRegistered(username);
            }
            onClosed: {
                transactionDialog.closed()
            }
        }
    }

    // TODO: Replace with StatusModal
    ModalPopup {
        id: popup
        //% "Terms of name registration"
        title: qsTrId("ens-terms-header")

        ScrollView {
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            width: parent.width
            height: parent.height
            clip: true

            Column {
                spacing: Style.current.halfPadding
                height: childrenRect.height
                width: parent.width
                

                StatusBaseText {
                    //% "Funds are deposited for 1 year. Your SNT will be locked, but not spent."
                    text: qsTrId("ens-terms-point-1")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "After 1 year, you can release the name and get your deposit back, or take no action to keep the name."
                    text: qsTrId("ens-terms-point-2")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "If terms of the contract change — e.g. Status makes contract upgrades — user has the right to release the username regardless of time held."
                    text: qsTrId("ens-terms-point-3")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "The contract controller cannot access your deposited funds. They can only be moved back to the address that sent them."
                    text: qsTrId("ens-terms-point-4")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "Your address(es) will be publicly associated with your ENS name."
                    text: qsTrId("ens-terms-point-5")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "Usernames are created as subdomain nodes of stateofus.eth and are subject to the ENS smart contract terms."
                    text: qsTrId("ens-terms-point-6")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "You authorize the contract to transfer SNT on your behalf. This can only occur when you approve a transaction to authorize the transfer."
                    text: qsTrId("ens-terms-point-7")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StatusBaseText {
                    //% "These terms are guaranteed by the smart contract logic at addresses:"
                    text: qsTrId("ens-terms-point-8")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.weight: Font.Bold
                }

                StatusBaseText {
                    //% "%1 (Status UsernameRegistrar)."
                    text: qsTrId("-1--status-usernameregistrar--").arg(root.store.getEnsUsernameRegistrar())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                }

                StatusBaseText {
                    //% "<a href='%1%2'>Look up on Etherscan</a>"
                    text: qsTrId("-a-href---1-2--look-up-on-etherscan--a-").arg(root.store.etherscanLink.replace("/tx", "/address")).arg(root.store.getEnsUsernameRegistrar())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: appMain.openLink(link)
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                StatusBaseText {
                    //% "%1 (ENS Registry)."
                    text: qsTrId("-1--ens-registry--").arg(root.store.getEnsRegistry())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                }

                StatusBaseText {
                    //% "<a href='%1%2'>Look up on Etherscan</a>"
                    text: qsTrId("-a-href---1-2--look-up-on-etherscan--a-").arg(root.store.etherscanLink.replace("/tx", "/address")).arg(root.store.getEnsRegistry())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: appMain.openLink(link)
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

            }
        }
    }

    ScrollView {
        id: sview
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: contentItem.childrenRect.height
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: startBtn.top
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right

        Item {
            id: contentItem
            anchors.right: parent.right;
            anchors.left: parent.left;

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
            }

            StatusDescriptionListItem {
                id: walletAddressLbl
                //% "Wallet address"
                title: qsTrId("wallet-address")
                subTitle: root.store.getWalletDefaultAddress()
                tooltip.text: qsTr("Copied to clipboard!")
                icon.name: "copy"
                iconButton.onClicked: {
                    root.store.copyToClipboard(subTitle)
                    tooltip.visible = !tooltip.visible
                }
                anchors.top: ensUsername.bottom
                anchors.topMargin: 24
            }

            StatusDescriptionListItem {
                id: keyLbl
                //% "Key"
                title: qsTrId("key")
                subTitle: {
                    let pubKey = root.store.pubKey;
                    return pubKey.substring(0, 20) + "..." + pubKey.substring(pubKey.length - 20);
                }
                tooltip.text: qsTr("Copied to clipboard!")
                icon.name: "copy"
                iconButton.onClicked: {
                    root.store.copyToClipboard(root.store.pubKey)
                    tooltip.visible = !tooltip.visible
                }
                anchors.top: walletAddressLbl.bottom
                anchors.topMargin: 24
            }

            StatusCheckBox {
                id: termsAndConditionsCheckbox
                anchors.top: keyLbl.bottom
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.leftMargin: 24
            }

            StatusBaseText {
                //% "Agree to <a href=\"#\">Terms of name registration.</a> I understand that my wallet address will be publicly connected to my username."
                text: qsTrId("agree-to--a-href-------terms-of-name-registration---a--i-understand-that-my-wallet-address-will-be-publicly-connected-to-my-username-")
                anchors.left: termsAndConditionsCheckbox.right
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                anchors.top: termsAndConditionsCheckbox.top
                onLinkActivated: popup.open()
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
        //% "Back"
        text: qsTrId("back")
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
            source: Style.svg("status-logo")
            sourceSize: Qt.size(width, height)
        }
        
        StatusBaseText {
            id: ensPriceLbl
            //% "10 SNT"
            text: qsTrId("ens-10-SNT")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.top: image1.top
            color: Theme.palette.directColor1
            font.pixelSize: 14
        }

        StatusBaseText {
            //% "Deposit"
            text: qsTrId("ens-deposit")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.top: ensPriceLbl.bottom
            color: Theme.palette.directColor7
            font.pixelSize: 14
        }
    }

    StatusButton {
        id: startBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: parseFloat(root.store.getSntBalance()) < 10 ?
          //% "Not enough SNT"
          qsTrId("not-enough-snt") :
          //% "Register"
          qsTrId("ens-register")
        enabled: parseFloat(root.store.getSntBalance()) >= 10 && termsAndConditionsCheckbox.checked
        onClicked: appSettings.isWalletEnabled ? transactionDialog.open() : confirmationPopup.open()
    }

    ConfirmationDialog {
        id: confirmationPopup
        showCancelButton: true
        confirmationText: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
        confirmButtonLabel: qsTr("I understand")
        onConfirmButtonClicked: {
            appSettings.isWalletEnabled = true
            close()
            transactionDialog.open()
        }

        onCancelButtonClicked: {
            close()
        }
    }
}
