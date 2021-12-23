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
    property var contacts
    property var selectedContact
    property var ensModule
    height: select.height
    property int dropdownWidth: width
    //% "Please select a contact"
    property string validationError: qsTrId("please-select-a-contact")
    property alias validationErrorAlignment: select.validationErrorAlignment
    property bool isValid: false
    property alias isPending: ensResolver.isPending

    property bool readOnly: false
    property bool isResolvedAddress: false
    //% "Select a contact"
    property string selectAContact: qsTrId("select-a-contact")
    //% "Contact does not have an ENS address. Please send a transaction in chat."
    property string noEnsAddressMessage: qsTrId("contact-does-not-have-an-ens-address--please-send-a-transaction-in-chat-")
    property bool isContact: false

    function resolveEns() {
        if (selectedContact.ensVerified) {
            root.isResolvedAddress = false
            ensResolver.resolveEns(selectedContact.name)
        }
    }

    onContactsChanged: {
        if (root.readOnly) {
            return
        }
        root.selectedContact = { name: selectAContact }
    }

    onSelectedContactChanged: validate()

    function validate() {
        if (!selectedContact) {
            return root.isValid
        }
        let isValidAddress = Utils.isValidAddress(selectedContact.address)
        let isDefaultValue = selectedContact.name === selectAContact
        let isValid = (selectedContact.ensVerified && isValidAddress) || isPending || isValidAddress
        select.validationError = ""
        if (!isValid && !isDefaultValue && 
            (
                !selectedContact.ensVerified ||
                (selectedContact.ensVerified && isResolvedAddress)
            )
        ) {
            select.validationError = !selectedContact.ensVerified ? noEnsAddressMessage : validationError
        }
        root.isValid = isValid
        return isValid
    }

    Input {
        id: inpReadOnly
        visible: root.readOnly
        width: parent.width
        //% "No contact selected"
        text: (root.selectedContact && root.selectedContact.name) ? root.selectedContact.name : qsTrId("no-contact-selected")
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

    StatusSelect {
        id: select
        label: ""
        model: root.contacts
        width: parent.width
        visible: !root.readOnly
        menuAlignment: StatusSelect.MenuAlignment.Left
        selectedItemComponent: Item {
            anchors.fill: parent
            StatusSmartIdenticon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                image.width: (!!selectedContact && !!selectedContact.identicon) ? 32 : 0
                image.height: 32
                image.source: (!!selectedContact && !!selectedContact.identicon) ? selectedContact.identicon : ""
                image.isIdenticon: true
                active: !!selectedContact && !!selectedContact.identicon
            }
            StatusBaseText {
                id: selectedTextField
                text: !!selectedContact ? selectedContact.name : ""
                anchors.left: iconImg.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                height: 22
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
            }
        }
        zeroItemsView: Item {
            height: 186
            StatusBaseText {
                anchors.fill: parent
                //% "You don’t have any contacts yet"
                text: qsTrId("you-don-t-have-any-contacts-yet")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                height: 18
                color: Theme.palette.baseColor1
            }
        }

        selectMenu.delegate: menuItem
        selectMenu.width: dropdownWidth
    }

    EnsResolver {
        id: ensResolver
        anchors.top: select.bottom
        anchors.right: select.right
        anchors.topMargin: Style.current.halfPadding
        debounceDelay: 0
        ensModule: root.ensModule
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

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            property bool isFirstItem: index === 0
            property bool isLastItem: index === contacts.rowCount() - 1

            width: parent.width
            height: visible ? 72 : 0
            StatusSmartIdenticon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                image.source: identicon
                image.isIdenticon: true
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                StatusBaseText {
                    text: name
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    height: 22
                }

                Row {
                    StatusBaseText {
                      text: alias + " • "
                      visible: ensVerified
                      color: Theme.palette.baseColor1
                      font.pixelSize: 12
                      height: 16
                    }
                    StatusBaseText {
                        text: address
                        width: 85
                        elide: Text.ElideMiddle
                        color: Theme.palette.baseColor1
                        font.pixelSize: 12
                        height: 16
                    }
                }
            }
            background: Rectangle {
                color: itemContainer.highlighted ? Theme.palette.statusSelect.menuItemHoverBackgroundColor : Theme.palette.statusSelect.menuItemBackgroundColor
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: itemContainer
                onClicked: {
                    root.selectedContact = { address, name, alias, isContact, identicon, ensVerified }
                    resolveEns()
                    select.selectMenu.close()
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
