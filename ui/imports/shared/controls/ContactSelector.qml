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
    height: select.height
    property int dropdownWidth: width
    property string validationError: qsTr("Please select a contact")
    property alias validationErrorAlignment: select.validationErrorAlignment
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

    StatusSelect {
        id: select
        label: ""
        model: root.contactsStore.myContactsModel
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
                image.width: (!!selectedContact && !!selectedContact.displayIcon) ? 32 : 0
                image.height: 32
                image.source: (!!selectedContact && !!selectedContact.displayIcon) ? selectedContact.displayIcon : ""
                active: !!selectedContact && !!selectedContact.displayIcon
            }
            StatusBaseText {
                id: selectedTextField
                text: !!selectedContact ? selectedContact.alias : ""
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
                text: qsTr("You don’t have any contacts yet")
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
            property bool isLastItem: index === root.contactsStore.myContactsModel.count - 1

            property var currentContact: Utils.getContactDetailsAsJson(pubKey)

            width: parent.width
            height: visible ? 72 : 0
            StatusSmartIdenticon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                image.source: currentContact.displayIcon
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                StatusBaseText {
                    text: currentContact.alias
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    height: 22
                }

                Row {
                    StatusBaseText {
                      text: currentContact.name + " • "
                      visible: currentContact.ensVerified
                      color: Theme.palette.baseColor1
                      font.pixelSize: 12
                      height: 16
                    }
                    StatusBaseText {
                        text: currentContact.publicKey
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
                    root.selectedContact = itemContainer.currentContact
                    resolveEns()
                    select.selectMenu.close()
                }
            }
        }
    }
}
