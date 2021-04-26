import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared/status"

Item {
    id: root
    property var contacts
    property var selectedContact
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
        textField.font.pixelSize: 15 * scaleAction.factor
        textField.color: Style.current.secondaryText
        readOnly: true
        validationErrorAlignment: TextEdit.AlignRight
        validationErrorTopMargin: 8
        customHeight: 56 * scaleAction.factor
    }

    Select {
        id: select
        label: ""
        model: root.contacts
        width: parent.width
        visible: !root.readOnly
        menuAlignment: Select.MenuAlignment.Left
        selectedItemView: Item {
            anchors.fill: parent
            StatusImageIdenticon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                height: 32 * scaleAction.factor
                width: (!!selectedContact && !!selectedContact.identicon) ? 32 * scaleAction.factor : 0
                visible: !!selectedContact && !!selectedContact.identicon
                source: (!!selectedContact && !!selectedContact.identicon) ? selectedContact.identicon : ""
            }

            StyledText {
                id: selectedTextField
                text: !!selectedContact ? selectedContact.name : ""
                anchors.left: iconImg.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15 * scaleAction.factor
                height: 22 * scaleAction.factor
                verticalAlignment: Text.AlignVCenter
            }
        }
        zeroItemsView: Item {
            height: 186 * scaleAction.factor
            StyledText {
                anchors.fill: parent
                //% "You don’t have any contacts yet"
                text: qsTrId("you-don-t-have-any-contacts-yet")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13 * scaleAction.factor
                height: 18 * scaleAction.factor
                color: Style.current.secondaryText
            }
        }

        menu.delegate: menuItem
        menu.width: dropdownWidth
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
            property bool isLastItem: index === contacts.rowCount() - 1

            width: parent.width
            height: visible ? 72 * scaleAction.factor : 0
            StatusImageIdenticon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                source: identicon
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: name
                    font.pixelSize: 15 * scaleAction.factor
                    font.family: Style.current.fontRegular.name
                    font.weight: Font.Medium
                    color: Style.current.textColor
                    height: 22 * scaleAction.factor
                }

                Row {
                    StyledText {
                      text: alias + " • "
                      visible: ensVerified
                      color: Style.current.secondaryText
                      font.pixelSize: 12 * scaleAction.factor
                      height: 16 * scaleAction.factor
                    }
                    StyledText {
                        text: address
                        width: 85 * scaleAction.factor
                        elide: Text.ElideMiddle
                        color: Style.current.secondaryText
                        font.pixelSize: 12 * scaleAction.factor
                        height: 16 * scaleAction.factor
                    }
                }
            }
            background: Rectangle {
                color: itemContainer.highlighted ? Style.current.backgroundHover : Style.current.background
                radius: Style.current.radius

                // cover bottom left/right corners with square corners
                Rectangle {
                    visible: !isLastItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }

                // cover top left/right corners with square corners
                Rectangle {
                    visible: !isFirstItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.radius
                    color: parent.color
                }
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: itemContainer
                onClicked: {
                    root.selectedContact = { address, name, alias, isContact, identicon, ensVerified }
                    resolveEns()
                    select.menu.close()
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
