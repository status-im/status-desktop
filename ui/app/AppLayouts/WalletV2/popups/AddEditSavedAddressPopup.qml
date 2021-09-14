import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root
    width: 574
    height: 490
    header.title: edit ? qsTr("Edit saved address") : qsTr("Add saved address")
    header.subTitle: edit ? name : qsTr("Unnamed")
    onOpened: {
        edit ?
            nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason) :
            addressInput.input.edit.forceActiveFocus(Qt.MouseFocusReason);
    }

    property var store
    property bool loading: false
    property bool edit: false
    property bool valid: addressInput.valid && nameInput.valid // TODO: Add network preference and emoji
    property bool dirty: addressInput.input.dirty && nameInput.input.dirty
    property alias address: addressInput.text
    property alias name: nameInput.text
    property int validationMode: edit ?
        StatusInput.ValidationMode.Always :
        StatusInput.ValidationMode.OnlyWhenDirty
    signal beforeSave()

    contentItem: Column {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: childrenRect.height

        StatusInput {
            id: addressInput
            input.leftIcon: false
            input.implicitHeight: 56
            input.placeholderText: qsTr("Enter a valid address or ENS name")
            label: qsTr("Address")
            validators: [
                StatusAddressOrEnsValidator {
                    errorMessage: qsTr("Invalid address or ENS name")
                },
                StatusMinLengthValidator {
                    errorMessage: qsTr("Please provide an address or ENS name")
                }
            ]
            validationMode: root.validationMode
            input.enabled: !root.edit
        }

        Row {
            id: accountNameInputRow
            anchors.left: parent.left
            anchors.right: parent.right
            height: 82
            spacing: 10
            Item {
                implicitWidth: 434
                height: parent.height
                StatusInput {
                    id: nameInput
                    anchors.fill: parent
                    input.implicitHeight: 56
                    input.placeholderText: qsTr("Enter a name")
                    label: qsTr("Name")
                    validators: [
                        StatusMinLengthValidator {
                            minLength: 1
                            errorMessage: qsTr("Name must not be blank")
                        }
                    ]
                    validationMode: root.validationMode
                }
            }
            Item {
                //emoji placeholder
                width: 80
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: 11
                StyledText {
                    id: inputLabel
                    text: "Emoji"
                    font.weight: Font.Medium
                    font.pixelSize: 13
                    color: Style.current.textColor
                }
                Rectangle {
                    width: parent.width
                    height: 56
                    anchors.top: inputLabel.bottom
                    anchors.topMargin: 7
                    radius: 10
                    color: "pink"
                    opacity: 0.6
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: root.edit ? qsTr("Save") : qsTr("Add address")
            enabled: !root.loading && root.valid && root.dirty
            loading: root.loading

            MessageDialog {
                id: accountError
                title: qsTr("Adding the account failed")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked: {
                root.loading = true;
                root.beforeSave();
                edit ?
                    root.store.walletModelV2Inst.savedAddressesView.editSavedAddress(name, address) :
                    root.store.walletModelV2Inst.savedAddressesView.addSavedAddress(name, address);
                root.close()
                root.loading = false;
            }
        }
    ]
}
