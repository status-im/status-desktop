import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

Item {
    property string username: ""

    signal backBtnClicked();
    signal usernameRegistered(userName: string);

    StyledText {
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
        sourceComponent: RegisterENSModal {
            onClosed: {
                transactionDialog.closed()
            }
            ensUsername: username
            width: 400
            height: 400
        }
    }

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
                

                StyledText {
                    //% "Funds are deposited for 1 year. Your SNT will be locked, but not spent."
                    text: qsTrId("ens-terms-point-1")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "After 1 year, you can release the name and get your deposit back, or take no action to keep the name."
                    text: qsTrId("ens-terms-point-2")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "If terms of the contract change — e.g. Status makes contract upgrades — user has the right to release the username regardless of time held."
                    text: qsTrId("ens-terms-point-3")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "The contract controller cannot access your deposited funds. They can only be moved back to the address that sent them."
                    text: qsTrId("ens-terms-point-4")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "Your address(es) will be publicly associated with your ENS name."
                    text: qsTrId("ens-terms-point-5")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "Usernames are created as subdomain nodes of stateofus.eth and are subject to the ENS smart contract terms."
                    text: qsTrId("ens-terms-point-6")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "You authorize the contract to transfer SNT on your behalf. This can only occur when you approve a transaction to authorize the transfer."
                    text: qsTrId("ens-terms-point-7")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    //% "These terms are guaranteed by the smart contract logic at addresses:"
                    text: qsTrId("ens-terms-point-8")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.weight: Font.Bold
                }

                StyledText {
                    //% "%1 (Status UsernameRegistrar)."
                    text: qsTrId("-1--status-usernameregistrar--").arg(profileModel.ens.getUsernameRegistrar())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                }

                StyledText {
                    text: qsTr(`<a href="%1%2">Look up on Etherscan</a>`).arg(walletModel.etherscanLink.replace("/tx", "/address")).arg(profileModel.ens.getUsernameRegistrar())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: appMain.openLink(link)
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                StyledText {
                    //% "%1 (ENS Registry)."
                    text: qsTrId("-1--ens-registry--").arg(profileModel.ens.getENSRegistry())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                }

                StyledText {
                    text: qsTr(`<a href="%1%2">Look up on Etherscan</a>`).arg(walletModel.etherscanLink.replace("/tx", "/address")).arg(profileModel.ens.getENSRegistry())
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

                StyledText {
                    text: "@"
                    opacity: 0.7
                    font.weight: Font.Bold
                    font.pixelSize: 18
                    color: Style.current.white
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            StyledText {
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

            TextWithLabel {
                id: walletAddressLbl
                //% "Wallet address"
                label: qsTrId("wallet-address")
                text: walletModel.getDefaultAddress()
                textToCopy: profileModel.profile.address
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: ensUsername.bottom
                anchors.topMargin: 24
            }

            TextWithLabel {
                id: keyLbl
                //% "Key"
                label: qsTrId("key")
                text: {
                    let pubKey = profileModel.profile.pubKey;
                    return pubKey.substring(0, 20) + "..." + pubKey.substring(pubKey.length - 20);
                }
                textToCopy: profileModel.profile.pubKey
                anchors.left: parent.left
                anchors.leftMargin: 24
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

            StyledText {
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
            width: 50
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            source: "../../../../../shared/img/status-logo.png"
        }
        
        StyledText {
            id: ensPriceLbl
            //% "10 SNT"
            text: qsTrId("ens-10-SNT")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.top: image1.top
            color: Style.current.textColor
            font.pixelSize: 14
        }

        StyledText {
            //% "Deposit"
            text: qsTrId("ens-deposit")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.top: ensPriceLbl.bottom
            color: Style.current.secondaryText
            font.pixelSize: 14
        }
    }

    StatusButton {
        id: startBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: parseFloat(utilsModel.getSNTBalance()) < 10 ?
          //% "Not enough SNT"
          qsTrId("not-enough-snt") :
          //% "Register"
          qsTrId("ens-register")
        enabled: parseFloat(utilsModel.getSNTBalance()) >= 10 && termsAndConditionsCheckbox.checked
        onClicked: transactionDialog.open()
    }
}
