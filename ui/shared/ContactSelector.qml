import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property var contacts
    property var selectedContact
    height: select.height + (validationErrorText.visible ? validationErrorText.height : 0)
    property int dropdownWidth: width
    property string validationError: validationErrorText.text
    property alias validationErrorAlignment: validationErrorText.horizontalAlignment

    onContactsChanged: {
        root.selectedContact = { name: qsTr("Select a contact") }
    }

    function validate() {
        const isValid = root.selectedContact && root.selectedContact.address
        if (!isValid) {
            select.select.border.color = Style.current.danger
            select.select.border.width = 1
            validationErrorText.visible = true
        } else {
            select.select.border.color = Style.current.transparent
            select.select.border.width = 0
            validationErrorText.visible = false
        }
    }

    Select {
        id: select
        label: ""
        model: root.contacts
        width: parent.width
        menuAlignment: Select.MenuAlignment.Left
        selectedItemView: Item {
            anchors.fill: parent
            Identicon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: !!selectedContact.identicon ? 32 : 0
                visible: !!selectedContact.identicon
                source: selectedContact.identicon ? selectedContact.identicon : ""
            }

            StyledText {
                id: selectedTextField
                text: selectedContact.name
                anchors.left: iconImg.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                height: 22
                verticalAlignment: Text.AlignVCenter
            }
        }
        zeroItemsView: Item {
            height: 186
            StyledText {
                anchors.fill: parent
                text: qsTr("You don't have any contacts yet")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                height: 18
                color: Style.current.secondaryText
            }
        }

        menu.delegate: menuItem
        menu.width: dropdownWidth
    }
    TextEdit {
        id: validationErrorText
        visible: false
        text: qsTr("Please select a contact")
        anchors.top: select.bottom
        anchors.topMargin: 8
        selectByMouse: true
        readOnly: true
        font.pixelSize: 12
        height: 16
        color: Style.current.danger
        width: parent.width
        horizontalAlignment: TextEdit.AlignRight
    }

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            property bool isFirstItem: index === 0
            property bool isLastItem: index === contacts.rowCount() - 1

            width: parent.width
            height: visible ? 72 : 0
            Identicon {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                source: identicon
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: name
                    font.pixelSize: 15
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
                      font.pixelSize: 12
                      height: 16
                    }
                    StyledText {
                        text: address
                        width: 85
                        elide: Text.ElideMiddle
                        color: Style.current.secondaryText
                        font.pixelSize: 12
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
