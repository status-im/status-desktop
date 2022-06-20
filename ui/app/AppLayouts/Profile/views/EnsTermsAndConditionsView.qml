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
        //% "ENS usernames"
        text: qsTrId("ens-usernames")
        anchors.left: parent.left
        anchors.leftMargin: Style.current.bigPadding
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        font.weight: Font.Bold
        font.pixelSize: Style.dp(20)
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
        sourceComponent: StatusSNTTransactionModal {
            store: root.ensUsernamesStore
            contactsStore: root.contactsStore
            stickersStore: root.stickersStore
            asyncGasEstimateTarget: root.stickersStore.stickersModule
            assetPrice: "10"
            chainId: root.ensUsernamesStore.getChainIdForEns()
            contractAddress: root.ensUsernamesStore.getEnsRegisteredAddress()
            estimateGasFunction: function(selectedAccount, uuid) {
                if (username === "" || !selectedAccount) return 380000;
                return root.ensUsernamesStore.registerEnsGasEstimate(username, selectedAccount.address)
            }
            onSendTransaction: function(selectedAddress, gasLimit, gasPrice, tipLimit, overallLimit, password, eip1559Enabled) {
                return root.ensUsernamesStore.registerEns(
                    username,
                    selectedAddress,
                    gasLimit,
                    gasPrice,
                    tipLimit,
                    overallLimit,
                    password, 
                    eip1559Enabled,
                )
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
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "After 1 year, you can release the name and get your deposit back, or take no action to keep the name."
                    text: qsTrId("ens-terms-point-2")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "If terms of the contract change — e.g. Status makes contract upgrades — user has the right to release the username regardless of time held."
                    text: qsTrId("ens-terms-point-3")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "The contract controller cannot access your deposited funds. They can only be moved back to the address that sent them."
                    text: qsTrId("ens-terms-point-4")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "Your address(es) will be publicly associated with your ENS name."
                    text: qsTrId("ens-terms-point-5")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "Usernames are created as subdomain nodes of stateofus.eth and are subject to the ENS smart contract terms."
                    text: qsTrId("ens-terms-point-6")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "You authorize the contract to transfer SNT on your behalf. This can only occur when you approve a transaction to authorize the transfer."
                    text: qsTrId("ens-terms-point-7")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "These terms are guaranteed by the smart contract logic at addresses:"
                    text: qsTrId("ens-terms-point-8")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.weight: Font.Bold
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "%1 (Status UsernameRegistrar)."
                    text: qsTrId("-1--status-usernameregistrar--").arg(root.ensUsernamesStore.getEnsRegisteredAddress())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "<a href='%1%2'>Look up on Etherscan</a>"
                    text: qsTrId("-a-href---1-2--look-up-on-etherscan--a-")
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
                    //% "%1 (ENS Registry)."
                    text: qsTrId("-1--ens-registry--").arg(root.ensUsernamesStore.getEnsRegistry())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    //% "<a href='%1%2'>Look up on Etherscan</a>"
                    text: qsTrId("-a-href---1-2--look-up-on-etherscan--a-")
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
                width: Style.dp(60)
                height: Style.dp(60)
                radius: Style.dp(120)
                color: Style.current.blue

                StatusBaseText {
                    text: "@"
                    opacity: 0.7
                    font.weight: Font.Bold
                    font.pixelSize: Style.dp(18)
                    color: Style.current.white
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            StatusBaseText {
                id: ensUsername
                text: username + ".stateofus.eth"
                font.weight: Font.Bold
                font.pixelSize: Style.dp(18)
                anchors.top: circleAt.bottom
                anchors.topMargin: Style.current.bigPadding
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.directColor1
            }

            StatusDescriptionListItem {
                id: walletAddressLbl
                //% "Wallet address"
                title: qsTrId("wallet-address")
                subTitle: root.ensUsernamesStore.getWalletDefaultAddress()
                tooltip.text: qsTr("Copied to clipboard!")
                icon.name: "copy"
                iconButton.onClicked: {
                    root.ensUsernamesStore.copyToClipboard(subTitle)
                    tooltip.visible = !tooltip.visible
                }
                anchors.top: ensUsername.bottom
                anchors.topMargin: Style.current.bigPadding
            }

            StatusDescriptionListItem {
                id: keyLbl
                //% "Key"
                title: qsTrId("key")
                subTitle: {
                    let pubKey = root.ensUsernamesStore.pubkey;
                    return pubKey.substring(0, 20) + "..." + pubKey.substring(pubKey.length - 20);
                }
                tooltip.text: qsTr("Copied to clipboard!")
                icon.name: "copy"
                iconButton.onClicked: {
                    root.ensUsernamesStore.copyToClipboard(root.ensUsernamesStore.pubkey)
                    tooltip.visible = !tooltip.visible
                }
                anchors.top: walletAddressLbl.bottom
                anchors.topMargin: Style.current.bigPadding
            }

            StatusCheckBox {
                id: termsAndConditionsCheckbox
                anchors.top: keyLbl.bottom
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.bigPadding
            }

            StatusBaseText {
                //% "Agree to <a href=\"#\">Terms of name registration.</a> I understand that my wallet address will be publicly connected to my username."
                text: qsTrId("agree-to--a-href-------terms-of-name-registration---a--i-understand-that-my-wallet-address-will-be-publicly-connected-to-my-username-")
                anchors.left: termsAndConditionsCheckbox.right
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                anchors.top: termsAndConditionsCheckbox.top
                onLinkActivated: popup.open()
                color: Theme.palette.directColor1
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
            height: Style.dp(50)
            width: height
            source: Style.png("tokens/SNT")
            sourceSize: Qt.size(width, height)
        }

        StatusBaseText {
            id: ensPriceLbl
            //% "10 SNT"
            text: qsTrId("ens-10-SNT")
            anchors.left: image1.right
            anchors.leftMargin: Style.dp(5)
            anchors.top: image1.top
            color: Theme.palette.directColor1
            font.pixelSize: Style.current.secondaryTextFontSize
        }

        StatusBaseText {
            //% "Deposit"
            text: qsTrId("ens-deposit")
            anchors.left: image1.right
            anchors.leftMargin: Style.dp(5)
            anchors.topMargin: Style.dp(5)
            anchors.top: ensPriceLbl.bottom
            color: Theme.palette.baseColor1
            font.pixelSize: Style.current.secondaryTextFontSize
        }
    }

    StatusButton {
        id: startBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: parseFloat(root.ensUsernamesStore.getSntBalance()) < 10 ?
          //% "Not enough SNT"
          qsTrId("not-enough-snt") :
          //% "Register"
          qsTrId("ens-register")
        enabled: parseFloat(root.ensUsernamesStore.getSntBalance()) >= 10 && termsAndConditionsCheckbox.checked
        onClicked: transactionDialog.open()
    }
}
