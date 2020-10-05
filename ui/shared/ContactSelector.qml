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
    property var reset: function() {}

    function resetInternal() {
        contacts = undefined
        selectedContact = undefined
        select.validationError = ""
        isValid = false
    }

    onContactsChanged: {
        //% "Select a contact"
        root.selectedContact = { name: qsTrId("select-a-contact") }
    }

    function validate() {
        const isValid = !!(selectedContact && selectedContact.address)
        select.validationError = !isValid ? validationError : ""
        root.isValid = isValid
        return isValid
    }

    Select {
        id: select
        label: ""
        model: root.contacts
        width: parent.width
        menuAlignment: Select.MenuAlignment.Left
        selectedItemView: Item {
            anchors.fill: parent
            StatusImageIdenticon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: (!!selectedContact && !!selectedContact.identicon) ? 32 : 0
                visible: !!selectedContact && !!selectedContact.identicon
                source: (!!selectedContact && !!selectedContact.identicon) ? selectedContact.identicon : ""
            }

            StyledText {
                id: selectedTextField
                text: !!selectedContact ? selectedContact.name : ""
                anchors.left: iconImg.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Style.current.primaryTextFontSize
                height: 22
                verticalAlignment: Text.AlignVCenter
            }
        }
        zeroItemsView: Item {
            height: 186
            StyledText {
                anchors.fill: parent
                //% "You don't have any contacts yet"
                text: qsTrId("you-don-t-have-any-contacts-yet")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Style.current.secondaryTextFontSize
                height: 18
                color: Style.current.secondaryText
            }
        }

        menu.delegate: menuItem
        menu.width: dropdownWidth
    }

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            property bool isFirstItem: index === 0
            property bool isLastItem: index === contacts.rowCount() - 1

            width: parent.width
            height: visible ? 72 : 0
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
                    font.pixelSize: Style.current.primaryTextFontSize
                    font.family: Style.current.fontRegular.name
                    font.weight: Font.Medium
                    color: Style.current.textColor
                    height: 22
                }

                Row {
                    StyledText {
                      text: alias + " • "
                      visible: ensVerified
                      color: Style.current.secondaryText
                      font.pixelSize: Style.current.tertiaryTextFontSize
                      height: 16
                    }
                    StyledText {
                        text: address
                        width: 85
                        elide: Text.ElideMiddle
                        color: Style.current.secondaryText
                        font.pixelSize: Style.current.tertiaryTextFontSize
                        height: 16
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
                    select.menu.close()
                    validate()
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
