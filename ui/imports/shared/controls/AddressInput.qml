import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "."

Item {
    id: root

    property var contactsStore

    property string validationError: "Error"
    property string ensAsyncValidationError: qsTr("ENS Username not found")
    property alias input: contactFieldAndList.chatKey
    property string selectedAddress
    property var isValid: false
    property alias isPending: contactFieldAndList.loading
    property bool isResolvedAddress: false
    property int parentWidth
    property bool addContactEnabled: true
    property alias wrongInputValidationError: contactFieldAndList.wrongInputValidationError

    height: contactFieldAndList.chatKey.height

    onSelectedAddressChanged: validate()

    function resetInternal() {
        selectedAddress = ""
        contactFieldAndList.chatKey.resetInternal()
        metrics.text = ""
        isValid = false
        isPending = false
        isResolvedAddress = false
    }

    function validate() {
        let isValidEns = Utils.isValidEns(input.text)
        let isValidAddress = Utils.isValidAddress(selectedAddress)
        let isValid = (isValidEns && !isResolvedAddress) || isPending || isValidAddress
        contactFieldAndList.chatKey.validationError = ""
        if (!isValid && input.text !== "") {
            contactFieldAndList.chatKey.validationError = isResolvedAddress ? ensAsyncValidationError : validationError
        }
        root.isValid = isValid
        return isValid
    }

    ContactsListAndSearch {
        id: contactFieldAndList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        showContactList: false
        addContactEnabled: root.addContactEnabled

        contactsStore: root.contactsStore

        onUserClicked: function (isContact, pubKey, ensName, address) {
            chatKey.text = address
        }
        searchResultsWidth: parentWidth
        chatKey.customHeight: 56
        chatKey.onFocusChanged: {
            root.validate()
            if (chatKey.text !== "" && Utils.isValidAddress(metrics.text)) {
                if (chatKey.focus) {
                    chatKey.text = metrics.text
                } else {
                    chatKey.text = metrics.elidedText
                }
            }
        }
        chatKey.onTextChanged: {
            metrics.text = chatKey.text
            if (Utils.isValidAddress(chatKey.text)) {
                root.selectedAddress = chatKey.text
            } else {
                root.selectedAddress = ""
            }
        }
        TextMetrics {
            id: metrics
            elideWidth: 97
            elide: Text.ElideMiddle
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
