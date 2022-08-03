import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml.Models 2.14

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups.Dialog 0.1

import "../stores"

StatusDialog {
    id: root

    property bool edit: false
    property string address
    property alias name: nameInput.text
    property var contactsStore

    signal save(string name, string address)

    QtObject {
        id: _internal
        property int validationMode: root.edit ?
                                         StatusInput.ValidationMode.Always
                                       : StatusInput.ValidationMode.OnlyWhenDirty
        property bool valid: addressInput.isValid && nameInput.valid // TODO: Add network preference and emoji
        property bool dirty: nameInput.input.dirty
    }

    width: 574
    height: 490

    header: StatusDialogHeader {
        headline.title: edit ? qsTr("Edit saved address") : qsTr("Add saved address")
        headline.subtitle: edit ? name : ""
    }

    onOpened: {
        if(edit) {
            addressInput.input.text = root.address
        }
        nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }

    Column {
        width: parent.width
        height: childrenRect.height
        topPadding: Style.current.xlPadding

        spacing: Style.current.bigPadding

        StatusInput {
            id: nameInput
            implicitWidth: parent.width
            input.edit.objectName: "savedAddressNameInput"
            minimumHeight: 56
            maximumHeight: 56
            placeholderText: qsTr("Enter a name")
            label: qsTr("Name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("Name must not be blank")
                },
                StatusRegularExpressionValidator {
                    regularExpression: /^[^<>]+$/
                    errorMessage: qsTr("This is not a valid account name")
                }
            ]
            charLimit: 40
            validationMode: _internal.validationMode
        }

        // To-Do use StatusInput within the below component
        RecipientSelector {
            id: addressInput
            implicitWidth: parent.width
            inputWidth: implicitWidth
            accounts: RootStore.accounts
            contactsStore: root.contactsStore
            label: qsTr("Address")
            input.textField.objectName: "savedAddressAddressInput"
            input.placeholderText: qsTr("Enter ENS Name or Ethereum Address")
            labelFont.pixelSize: 15
            labelFont.weight: Font.Normal
            input.implicitHeight: 56
            input.textField.anchors.rightMargin: 0
            isSelectorVisible: false
            addContactEnabled: false
            onSelectedRecipientChanged: {
                root.address = selectedRecipient.address
            }
            readOnly: root.edit
            wrongInputValidationError: qsTr("Please enter a valid ENS name OR Ethereum Address")
        }
    }

    footer: StatusDialogFooter {
        rightButtons:  ObjectModel {
            StatusButton {
                text: root.edit ? qsTr("Save") : qsTr("Add address")
                enabled: _internal.valid && _internal.dirty
                onClicked: root.save(name, address)
                objectName: "addSavedAddress"
            }
        }
    }
}
