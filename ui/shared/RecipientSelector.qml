import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property var accounts
    property var contacts
    property int inputWidth: 272
    property int sourceSelectWidth: 136
    property alias label: txtLabel.text
    // If supplied, additional info will be displayed top-right in danger colour (red)
    property alias additionalInfo: txtAddlInfo.text
    property var selectedRecipient: { }
    property bool readOnly: false
    height: (readOnly ? inpReadOnly.height : inpAddress.height) + txtLabel.height
    //% "Invalid ethereum address"
    readonly property string addressValidationError: qsTrId("invalid-ethereum-address")
    property bool isValid: false
    property var reset: function() {}
    readonly property var sources: [
        qsTr("Address"),
        qsTr("Contact"),
        qsTr("My account")
    ]

    function resetInternal() {
        inpAddress.resetInternal()
        selContact.resetInternal()
        selAccount.resetInternal()
        selAddressSource.resetInternal()
        selContact.reset()
        selAccount.reset()
        selAddressSource.reset()
        isValid = false
    }
    
    enum Type {
        Address,
        Contact,
        Account
    }

    function validate() {
        let isValid = true
        if (readOnly) {
            isValid = Utils.isValidAddress(selectedRecipient.address)
            if (!isValid) {
                inpReadOnly.validationError = addressValidationError
            }
        } else if (selAddressSource.selectedSource === "Address") {
            isValid = inpAddress.validate()
        } else if (selAddressSource.selectedSource === "Contact") {
            isValid = selContact.validate()
        }
        root.isValid = isValid
        return isValid
    }

    Text {
        id: txtLabel
        visible: label !== ""
        //% "Recipient"
        text: qsTrId("recipient")
        font.pixelSize: 13
        font.family: Style.current.fontRegular.name
        font.weight: Font.Medium
        color: Style.current.textColor
        height: 18
    }

    Text {
        id: txtAddlInfo
        visible: text !== ""
        text: ""
        font.pixelSize: 13
        font.family: Style.current.fontRegular.name
        font.weight: Font.Medium
        color: Style.current.danger
        height: 18
        anchors.right: parent.right
    }

    RowLayout {
        anchors.top: txtLabel.bottom
        anchors.topMargin: 7
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        Input {
            id: inpReadOnly
            visible: root.readOnly
            Layout.preferredWidth: selAddressSource.visible ? root.inputWidth : parent.width
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            anchors.left: undefined
            anchors.right: undefined
            //% "No recipient selected"
            text: (root.selectedRecipient && root.selectedRecipient.name) ? root.selectedRecipient.name : qsTrId("no-recipient-selected")
            textField.leftPadding: 14
            textField.topPadding: 18
            textField.bottomPadding: 18
            textField.verticalAlignment: TextField.AlignVCenter
            textField.font.pixelSize: 15
            textField.color: Style.current.secondaryText
            textField.readOnly: true
            validationErrorAlignment: TextEdit.AlignRight
            validationErrorTopMargin: 8
            customHeight: 56
        }

        AddressInput {
            id: inpAddress
            width: root.inputWidth
            label: ""
            visible: !root.readOnly
            Layout.preferredWidth: selAddressSource.visible ? root.inputWidth : parent.width
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            validationError: root.addressValidationError
            onSelectedAddressChanged: {
                if (root.readOnly) {
                    return
                }
                root.selectedRecipient = { address: selectedAddress, type: RecipientSelector.Type.Address }
            }
            onIsValidChanged: {
                if (selAddressSource.selectedSource === "Address") {
                    root.isValid = isValid
                }
            }
        }

        ContactSelector {
            id: selContact
            contacts: root.contacts
            visible: false
            width: root.inputWidth
            dropdownWidth: parent.width
            Layout.preferredWidth: selAddressSource.visible ? root.inputWidth : parent.width
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            reset: function() {
                contacts = root.contacts
            }
            onSelectedContactChanged: {
                if (root.readOnly) {
                    return
                }
                if(selectedContact && selectedContact.address) {
                    const { address, name, alias, isContact, identicon, ensVerified } = selectedContact
                    root.selectedRecipient = { address, name, alias, isContact, identicon, ensVerified, type: RecipientSelector.Type.Contact }
                }
            }
            onIsValidChanged: {
                if (selAddressSource.selectedSource === "Contact") {
                    root.isValid = isValid
                }
            }
        }

        AccountSelector {
            id: selAccount
            accounts: root.accounts
            visible: false
            width: root.inputWidth
            dropdownWidth: parent.width
            label: ""
            Layout.preferredWidth: selAddressSource.visible ? root.inputWidth : parent.width
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            reset: function() {
                accounts = root.accounts
            }
            onSelectedAccountChanged: {
                if (root.readOnly || !selectedAccount) {
                    return
                }
                const { address, name, iconColor, assets, fiatBalance } = selectedAccount
                root.selectedRecipient = { address, name, iconColor, assets, fiatBalance, type: RecipientSelector.Type.Account }
            }
        }
        AddressSourceSelector {
            id: selAddressSource
            visible: !root.readOnly
            sources: root.sources
            width: sourceSelectWidth
            Layout.preferredWidth: root.sourceSelectWidth
            Layout.alignment: Qt.AlignTop
            reset: function() {
                sources = root.sources
            }
            onSelectedSourceChanged: {
                if (root.readOnly) {
                    return
                }
                let address, name
                switch (selectedSource) {
                    case "Address":
                        inpAddress.visible = true
                        selContact.visible = selAccount.visible = false
                        root.height = Qt.binding(function() { return inpAddress.height + txtLabel.height })
                        root.selectedRecipient = { address: inpAddress.selectedAddress, type: RecipientSelector.Type.Address }
                        root.isValid = inpAddress.isValid
                        break;
                    case "Contact":
                        selContact.visible = true
                        inpAddress.visible = selAccount.visible = false
                        root.height = Qt.binding(function() { return selContact.height + txtLabel.height })
                        let { alias, isContact, identicon, ensVerified } = selContact.selectedContact
                        address = selContact.selectedContact.address
                        name = selContact.selectedContact.name
                        root.selectedRecipient = { address, name, alias, isContact, identicon, ensVerified, type: RecipientSelector.Type.Contact }
                        root.isValid = selContact.isValid
                        break;
                    case "My account":
                        selAccount.visible = true
                        inpAddress.visible = selContact.visible = false
                        root.height = Qt.binding(function() { return selAccount.height + txtLabel.height })
                        const { iconColor, assets, fiatBalance } = selAccount.selectedAccount
                        address = selAccount.selectedAccount.address
                        name = selAccount.selectedAccount.name
                        root.selectedRecipient = { address, name, iconColor, assets, fiatBalance, type: RecipientSelector.Type.Account }
                        root.isValid = selAccount.isValid
                        break;
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
