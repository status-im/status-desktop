import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string channelName
    property string gasLimit: "150000"
    // in gwei
    property string gasPrice: "1"

    property var signTransaction: function () {}

    property var selectedAccount

    property alias transactionSigner: transactionSigner

    id: root

    //% "Send"
    title: qsTrId("command-button-send")
    height: 504

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    onClosed: {
        stack.reset()
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }

        TransactionFormGroup {
            id: group1
            //% "Transaction preview"
            headerText: qsTrId("transaction-preview")
            //% "Sign with password"
            footerText: qsTrId("sign-with-password")

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: root.selectedAccount
                gas: {
                    "value": "150000",
                    "symbol": "xDAI",
                    "fiatValue": ""
                }
                toAccount: ({
                                address: Constants.channelsContractAddress,
                                identicon: "",
                                name: "Moderated Channels Contract",
                                type: RecipientSelector.Type.Address
                            })
                asset: ({
                            name: "xDai",
                            symbol: "xDai",
                            address: "0x3e50bf6703fc132a94e4baff068db2055655f11b"
                        })
                amount: { "value": "0", "fiatValue": "0" }
                currency: walletModel.defaultCurrency
                reset: function() {}
            }
        }
        TransactionFormGroup {
            id: group3
            //% "Sign with password"
            headerText: qsTrId("sign-with-password")
            footerText: qsTr("Send")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: walletModel.signingPhrase
                reset: function() {
                    signingPhrase = Qt.binding(function() { return walletModel.signingPhrase })
                }
            }
        }
    }

    footer: Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        StyledButton {
            id: btnBack
            anchors.left: parent.left
            width: 44
            height: 44
            visible: !stack.isFirstGroup
            label: ""
            background: Rectangle {
                anchors.fill: parent
                border.width: 0
                radius: width / 2
                color: btnBack.hovered ? Qt.darker(btnBack.btnColor, 1.1) : btnBack.btnColor

                SVGImage {
                    width: 20.42
                    height: 15.75
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../../../img/arrow-right.svg"
                    rotation: 180
                }
            }
            onClicked: {
                stack.back()
            }
        }
        StatusButton {
            id: btnNext
            anchors.right: parent.right
            //% "Next"
            text: qsTrId("next")
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        stack.currentGroup.isPending = true
                        return root.signTransaction(selectedAccount.address, Constants.channelsContractAddress, root.gasLimit, root.gasPrice, transactionSigner.enteredPassword)
                    }
                    stack.next()
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

