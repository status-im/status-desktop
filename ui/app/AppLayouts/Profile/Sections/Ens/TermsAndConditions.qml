import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"

Item {
    property var onClick: function(){}

    property string username: ""

    signal backBtnClicked();

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

    ModalPopup {
        id: popup
        title: qsTr("Terms of name registration")

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
                    text: qsTr("Funds are deposited for 1 year. Your SNT will be locked, but not spent.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("After 1 year, you can release the name and get your deposit back, or take no action to keep the name.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("If terms of the contract change — e.g. Status makes contract upgrades — user has the right to release the username regardless of time held.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("The contract controller cannot access your deposited funds. They can only be moved back to the address that sent them.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("Your address(es) will be publicly associated with your ENS name.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("Usernames are created as subdomain nodes of stateofus.eth and are subject to the ENS smart contract terms.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("You authorize the contract to transfer SNT on your behalf. This can only occur when you approve a transaction to authorize the transfer.")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                StyledText {
                    text: qsTr("These terms are guaranteed by the smart contract logic at addresses:")
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.weight: Font.Bold
                }

                StyledText {
                    text: qsTr("%1 (Status UsernameRegistrar).").arg(profileModel.ens.getUsernameRegistrar())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                }

                StyledText {
                    text: qsTr(`<a href="%1%2">Look up on Etherscan</a>`).arg(walletModel.etherscanLink.replace("/tx", "/address")).arg(profileModel.ens.getUsernameRegistrar())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: Qt.openUrlExternally(link)
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                StyledText {
                    text: qsTr("%1 (ENS Registry).").arg(profileModel.ens.getENSRegistry())
                    wrapMode: Text.WordWrap
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: Style.current.fontHexRegular.name
                }

                StyledText {
                    text: qsTr(`<a href="%1%2">Look up on Etherscan</a>`).arg(walletModel.etherscanLink.replace("/tx", "/address")).arg(profileModel.ens.getENSRegistry())
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onLinkActivated: Qt.openUrlExternally(link)
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
                label: qsTr("Wallet address")
                text: walletModel.getDefaultAddress()
                textToCopy: profileModel.profile.address
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: ensUsername.bottom
                anchors.topMargin: 24
            }

            TextWithLabel {
                id: keyLbl
                label: qsTr("Key")
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

            CheckBox {
                id: termsAndConditionsCheckbox
                anchors.top: keyLbl.bottom
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.leftMargin: 24
            }

            StyledText {
                text: qsTr("Agree to <a href=\"#\">Terms of name registration.</a> I understand that my wallet address will be publicly connected to my username.")
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

    StyledButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        label: qsTr("Back")
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
            text: qsTr("10 SNT")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.top: image1.top
            color: Style.current.textColor
            font.pixelSize: 14
        }

        StyledText {
            text: qsTr("Deposit")
            anchors.left: image1.right
            anchors.leftMargin: 5
            anchors.topMargin: 5
            anchors.top: ensPriceLbl.bottom
            color: Style.current.secondaryText
            font.pixelSize: 14
        }
    }

    StyledButton {
        id: startBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        label: parseFloat(walletModel.getSNTBalance()) < 10 ? qsTr("Not enough SNT") : qsTr("Ok")
        disabled: parseFloat(walletModel.getSNTBalance()) < 10 || !termsAndConditionsCheckbox.checked
        onClicked: onClick()
    }
}