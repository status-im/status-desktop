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
    property var selectedRecipient
    property bool readOnly: false
    height: inpAddress.height + txtLabel.height
    //% "Invalid ethereum address"
    readonly property string addressValidationError: qsTrId("invalid-ethereum-address")
    property bool isValid: false
    property bool isPending: {
        if (!selAddressSource.selectedSource) {
            return false
        }
        switch (selAddressSource.selectedSource.value) {
            case RecipientSelector.Type.Address:
                return inpAddress.isPending
            case RecipientSelector.Type.Contact:
                return selContact.isPending
            case RecipientSelector.Type.Account:
                return false // AccountSelector is never pending
        }
    }
    readonly property var sources: [
        //% "Address"
        { text: qsTrId("address"), value: RecipientSelector.Type.Address, visible: true },
        //% "My account"
        { text: qsTrId("my-account"), value: RecipientSelector.Type.Account, visible: true },
        { text: qsTr("Contact"), value: RecipientSelector.Type.Contact, visible: true }
    ]
    property var selectedType: RecipientSelector.Type.Address
    
    enum Type {
        Address,
        Contact,
        Account
    }

    function validate() {
        let isValid = true
        if (!selAddressSource.selectedSource) {
            return root.isValid
        }
        switch (selAddressSource.selectedSource.value) {
            case RecipientSelector.Type.Address:
                isValid = inpAddress.isValid
                break
            case RecipientSelector.Type.Contact:
                isValid = selContact.isValid
                break
            case RecipientSelector.Type.Account:
                isValid = selAccount.isValid
                break
        }
        root.isValid = isValid
        return isValid
    }

    function getSourceByType(type) {
        return root.sources.find(source => source.value === type)
    }

    onSelectedTypeChanged: {
        if (selectedType !== undefined) {
            selAddressSource.selectedSource = getSourceByType(selectedType)
        }
        if (!selectedRecipient) {
            return
        }
        switch (root.selectedType) {
            case RecipientSelector.Type.Address:
                inpAddress.text = selectedRecipient.name || ""
                inpAddress.visible = true
                selContact.visible = selAccount.visible = false
                if(!!selectedRecipient.address){
                    inpAddress.selectedAddress = selectedRecipient.address
                }
                break
            case RecipientSelector.Type.Contact:
                selContact.selectedContact = selectedRecipient
                // TODO: we shouldn't have to call resolveEns from the outside.
                // It should be handled automatically when selectedContact is
                // updated, however, handling it on property change causes an
                // infinite loop
                selContact.resolveEns()
                selContact.visible = true
                inpAddress.visible = selAccount.visible = false
                break
            case RecipientSelector.Type.Account:
                selAccount.selectedAccount = selectedRecipient
                selAccount.visible = true
                inpAddress.visible = selContact.visible = false
                break
        }
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

        AddressInput {
            id: inpAddress
            width: root.inputWidth
            label: ""
            readOnly: root.readOnly
            visible: true
            Layout.preferredWidth: selAddressSource.visible ? root.inputWidth : parent.width
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            validationError: root.addressValidationError
            onSelectedAddressChanged: {
                if (!selAddressSource.selectedSource || (selAddressSource.selectedSource && selAddressSource.selectedSource.value !== RecipientSelector.Type.Address)) {
                    return
                }

                root.selectedRecipient = { address: selectedAddress, type: RecipientSelector.Type.Address }
            }
            onIsValidChanged: root.validate()
        }

        ContactSelector {
            id: selContact
            contacts: root.contacts
            visible: false
            width: root.inputWidth
            dropdownWidth: parent.width
            readOnly: root.readOnly
            Layout.preferredWidth: selAddressSource.visible ? root.inputWidth : parent.width
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            onSelectedContactChanged: {
                if (!selectedContact || !selAddressSource.selectedSource || !selectedContact.address || (selAddressSource.selectedSource && selAddressSource.selectedSource.value !== RecipientSelector.Type.Contact)) {
                    return
                }
                const { address, name, alias, isContact, identicon, ensVerified } = selectedContact
                root.selectedRecipient = { address, name, alias, isContact, identicon, ensVerified, type: RecipientSelector.Type.Contact }
            }
            onIsValidChanged: root.validate()
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
            onSelectedAccountChanged: {
                if (!selectedAccount || !selAddressSource.selectedSource || (selAddressSource.selectedSource && selAddressSource.selectedSource.value !== RecipientSelector.Type.Account)) {
                    return
                }
                const { address, name, iconColor, assets, fiatBalance } = selectedAccount
                root.selectedRecipient = { address, name, iconColor, assets, fiatBalance, type: RecipientSelector.Type.Account }
            }
            onIsValidChanged: root.validate()
        }
        AddressSourceSelector {
            id: selAddressSource
            visible: !root.readOnly
            sources: root.sources.filter(source => source.visible)
            width: sourceSelectWidth
            Layout.preferredWidth: root.sourceSelectWidth
            Layout.alignment: Qt.AlignTop

            onSelectedSourceChanged: {
                if (root.readOnly || !selectedSource) {
                    return
                }
                let address, name
                switch (selectedSource.value) {
                    case RecipientSelector.Type.Address:
                        inpAddress.visible = true
                        selContact.visible = selAccount.visible = false
                        root.height = Qt.binding(function() { return inpAddress.height + txtLabel.height })
                        root.selectedRecipient = { address: inpAddress.selectedAddress, type: RecipientSelector.Type.Address }
                        if (root.selectedType !== RecipientSelector.Type.Address) root.selectedType = RecipientSelector.Type.Address
                        root.isValid = inpAddress.isValid
                        break;
                    case RecipientSelector.Type.Contact:
                        selContact.visible = true
                        inpAddress.visible = selAccount.visible = false
                        root.height = Qt.binding(function() { return selContact.height + txtLabel.height })
                        let { alias, isContact, identicon, ensVerified } = selContact.selectedContact
                        address = selContact.selectedContact.address
                        name = selContact.selectedContact.name
                        root.selectedRecipient = { address, name, alias, isContact, identicon, ensVerified, type: RecipientSelector.Type.Contact }
                        if (root.selectedType !== RecipientSelector.Type.Contact) root.selectedType = RecipientSelector.Type.Contact
                        root.isValid = selContact.isValid
                        break;
                    case RecipientSelector.Type.Account:
                        selAccount.visible = true
                        inpAddress.visible = selContact.visible = false
                        root.height = Qt.binding(function() { return selAccount.height + txtLabel.height })
                        const { iconColor, assets, fiatBalance } = selAccount.selectedAccount
                        address = selAccount.selectedAccount.address
                        name = selAccount.selectedAccount.name
                        root.selectedRecipient = { address, name, iconColor, assets, fiatBalance, type: RecipientSelector.Type.Account }
                        if (root.selectedType !== RecipientSelector.Type.Account) root.selectedType = RecipientSelector.Type.Account
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
