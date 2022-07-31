import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../views"
import "../panels"
import "./"

Item {
    id: root
    property var contactsStore
    property var selectedContact
    property int dropdownWidth: width
    property string validationError: qsTr("Please select a contact")
//    property alias validationErrorAlignment: comboBox.validationErrorAlignment
    property bool isValid: false
    property alias isPending: ensResolver.isPending

    property bool readOnly: false
    property bool isResolvedAddress: false
    property string selectAContact: qsTr("Select a contact")
    property string noEnsAddressMessage: qsTr("Contact does not have an ENS address. Please send a transaction in chat.")

    function resolveEns() {
        if (selectedContact.ensVerified) {
            root.isResolvedAddress = false
            ensResolver.resolveEns(selectedContact.alias)
        }
    }

    implicitHeight: comboBox.implicitHeight

    Component.onCompleted: {
        if (root.readOnly) {
            return
        }
        root.selectedContact = { alias: selectAContact }
    }

    onSelectedContactChanged: validate()

    function validate() {
        if (!selectedContact) {
            return root.isValid
        }
        let isValidAddress = Utils.isValidAddress(selectedContact.address)
        let isDefaultValue = selectedContact.alias === selectAContact
        let isValid = (selectedContact.ensVerified && isValidAddress) || isPending || isValidAddress
        comboBox.validationError = ""
        if (!isValid && !isDefaultValue &&
            (
                !selectedContact.ensVerified ||
                (selectedContact.ensVerified && isResolvedAddress)
            )
        ) {
            comboBox.validationError = !selectedContact.ensVerified ? noEnsAddressMessage : validationError
        }
        root.isValid = isValid
        return isValid
    }

    Input {
        id: inpReadOnly
        visible: root.readOnly
        width: parent.width
        text: (root.selectedContact && root.selectedContact.alias) ? root.selectedContact.alias : qsTr("No contact selected")
        textField.leftPadding: 14
        textField.topPadding: 18
        textField.bottomPadding: 18
        textField.verticalAlignment: TextField.AlignVCenter
        textField.font.pixelSize: 15
        textField.color: Style.current.secondaryText
        readOnly: true
        validationErrorAlignment: TextEdit.AlignRight
        validationErrorTopMargin: 8
        customHeight: 56
    }

    StatusComboBox {
        id: comboBox
        label: ""
        model: root.contactsStore.myContactsModel
        width: parent.width
        visible: !root.readOnly

        control.popup.width: dropdownWidth
        control.padding: 14

        enabled: control.count > 0

        contentItem: RowLayout {
            spacing: 4

            StatusSmartIdenticon {
                image.width: (!!selectedContact && !!selectedContact.displayIcon) ? 32 : 0
                image.height: 32
                image.source: (!!selectedContact && !!selectedContact.displayIcon) ? selectedContact.displayIcon : ""
                active: !!selectedContact && !!selectedContact.displayIcon
            }
            StatusBaseText {
                id: selectedTextField
                visible: comboBox.control.count > 0
                text: !!selectedContact ? selectedContact.alias : ""
                font.pixelSize: 15
                height: 22
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                visible: comboBox.control.count == 0
                text: qsTr("You don’t have any contacts yet")
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }
        }

        delegate: StatusItemDelegate {
            id: itemContainer
            property var currentContact: Utils.getContactDetailsAsJson(pubKey)

            highlighted: index === comboBox.control.highlightedIndex
            width: parent.width

            onClicked: {
                root.selectedContact = itemContainer.currentContact
            }

            contentItem: RowLayout {
                spacing: 12

                StatusSmartIdenticon {
                    image.source: currentContact.displayIcon
                }
                ColumnLayout {
                    Layout.fillWidth: true

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: currentContact.alias
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        StatusBaseText {
                            Layout.fillWidth: true
                            text: currentContact.name + " • "
                            visible: currentContact.ensVerified
                            color: Theme.palette.baseColor1
                            font.pixelSize: 12
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 85
                            text: currentContact.publicKey
                            elide: Text.ElideMiddle
                            color: Theme.palette.baseColor1
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

    }

    EnsResolver {
        id: ensResolver
        anchors.top: comboBox.bottom
        anchors.right: comboBox.right
        anchors.topMargin: Style.current.halfPadding
        debounceDelay: 0
        onResolved: {
            root.isResolvedAddress = true
            var selectedContact = root.selectedContact
            selectedContact.address = resolvedAddress
            root.selectedContact = selectedContact
        }
        onIsPendingChanged: {
            if (isPending) {
                root.selectedContact.address = ""
            }
        }
    }
}
