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
    property string label: qsTr("Recipient")
    property string selectedRecipient: ""
    height: inpAddress.height + txtLabel.height

    function validate() {
        if (selAddressSource.selectedSource === "Address") {
            inpAddress.validate()
        } else if (selAddressSource.selectedSource === "Contact") {
            selContact.validate()
        }
    }

    Text {
        id: txtLabel
        visible: label !== ""
        text: root.label
        font.pixelSize: 13
        font.family: Style.current.fontBold.name
        color: Style.current.textColor
        height: 18
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
            Layout.preferredWidth: root.inputWidth
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            validationError: qsTr("Invalid ethereum address")
            onSelectedAddressChanged: {
                root.selectedRecipient = selectedAddress
            }
        }

        ContactSelector {
            id: selContact
            contacts: root.contacts
            visible: false
            width: root.inputWidth
            dropdownWidth: parent.width
            Layout.preferredWidth: root.inputWidth
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            onSelectedContactChanged: {
                if(selectedContact && selectedContact.address) {
                    root.selectedRecipient = selectedContact.address
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
            Layout.preferredWidth: root.inputWidth
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            onSelectedAccountChanged: {
                root.selectedRecipient = selectedAccount.address
            }
        }
        AddressSourceSelector {
            id: selAddressSource
            sources: ["Address", "Contact", "My account"]
            width: sourceSelectWidth
            Layout.preferredWidth: root.sourceSelectWidth
            Layout.alignment: Qt.AlignTop

            onSelectedSourceChanged: {
                switch (selectedSource) {
                    case "Address":
                        inpAddress.visible = true
                        selContact.visible = selAccount.visible = false
                        root.height = Qt.binding(function() { return inpAddress.height + txtLabel.height })
                        break;
                    case "Contact":
                        selContact.visible = true
                        inpAddress.visible = selAccount.visible = false
                        root.height = Qt.binding(function() { return selContact.height + txtLabel.height })
                        break;
                    case "My account":
                        selAccount.visible = true
                        inpAddress.visible = selContact.visible = false
                        root.height = Qt.binding(function() { return selAccount.height + txtLabel.height })
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
