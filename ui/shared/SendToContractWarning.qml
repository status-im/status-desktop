import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    //% "Tokens will be sent directly to a contract address, which may result in a loss of funds. To transfer ERC-20 tokens, ensure the recipient address is the address of the destination wallet."
    property string sendToContractWarningMessage: qsTrId("tokens-will-be-sent-directly-to-a-contract-address--which-may-result-in-a-loss-of-funds--to-transfer-erc-20-tokens--ensure-the-recipient-address-is-the-address-of-the-destination-wallet-")
    property var selectedRecipient
    property bool isValid: true

    onSelectedRecipientChanged: validate()

    function validate() {
        let isValid = true
        if (!(selectedRecipient && selectedRecipient.address)) {
            return root.isValid
        }
        txtValidationError.text = ""
        if (walletModel.isKnownTokenContract(selectedRecipient.address)) {
            // do not set isValid = false here because it would make the
            // TransactionStackGroup invalid and therefore not let the user
            // continue in the modal
            txtValidationError.text = sendToContractWarningMessage
        }
        return isValid
    }

    Column {
        id: colValidation
        anchors.horizontalCenter: parent.horizontalCenter
        visible: txtValidationError.text !== ""
        spacing: 5

        SVGImage {
            id: imgExclamation
            width: 13.33
            height: 13.33
            sourceSize.height: height * 2
            sourceSize.width: width * 2
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: "../app/img/exclamation_outline.svg"
        }
        StyledText {
            id: txtValidationError
            text: ""
            width: root.width
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            color: Style.current.danger
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
            wrapMode: Text.WordWrap
        }
    }
}
