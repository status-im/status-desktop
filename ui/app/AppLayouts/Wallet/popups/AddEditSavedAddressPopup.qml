import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import "../stores"

StatusModal {
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
    header.title: edit ? qsTr("Edit saved address") : qsTr("Add saved address")
    header.subTitle: edit ? name : ""

    onOpened: {
        if(edit) {
            addressInput.input.text = root.address
        }
        nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }

    contentItem: Column {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: childrenRect.height
        topPadding: Style.current.xlPadding

        spacing: Style.current.bigPadding

        StatusInput {
            id: nameInput
            width: parent.width
            input.implicitHeight: 56
            input.placeholderText: qsTr("Enter a name")
            label: qsTr("Name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("Name must not be blank")
                }
            ]
            validationMode: _internal.validationMode
        }

        // To-Do use StatusInput within the below component
        Item {
            width: parent.width
            height: addressInput.height
            RecipientSelector {
                id: addressInput
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.top: parent.top
                width: parent.width
                accounts: RootStore.accounts
                contactsStore: root.contactsStore
                label: qsTr("Address")
                labelFont.pixelSize: 15
                labelFont.weight: Font.Normal
                input.implicitHeight: 56
                isSelectorVisible: false
                addContactEnabled: false
                onSelectedRecipientChanged: {
                    root.address = selectedRecipient.address
                }
                readOnly: root.edit
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: root.edit ? qsTr("Save") : qsTr("Add address")
            enabled: _internal.valid && _internal.dirty
            onClicked: save(name, address)
        }
    ]
}
