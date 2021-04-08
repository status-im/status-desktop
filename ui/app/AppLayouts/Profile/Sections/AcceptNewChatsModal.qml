import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    title: qsTr("Accept new chats from")

    onClosed: {
        destroy()
    }

    Column {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        ButtonGroup {
            id: acceptsNewChatsFromGroup
        }

        StatusRadioButtonRow {
            text: qsTr("Anyone")
            buttonGroup: acceptsNewChatsFromGroup
            checked: !profileModel.profile.acceptChatsContactsOnly
            onRadioCheckedChanged: {
                if (checked) {
                    profileModel.setAcceptChatsContactsOnly(false)
                }
            }
        }
        StatusRadioButtonRow {
            text: qsTr("Contacts")
            buttonGroup: acceptsNewChatsFromGroup
            checked: profileModel.profile.acceptChatsContactsOnly
            onRadioCheckedChanged: {
                if (checked) {
                    profileModel.setAcceptChatsContactsOnly(true)
                }
            }
        }
        StyledText {
            text: qsTr("Only people you added as a contact can start a new chat with you or invite you to a group")
            color: Style.current.secondaryText
            width: parent.width
            wrapMode: Text.WordWrap

        }
        StyledText {
            text: qsTr("You need to restart the app for old group invites to disapear. This will be improved in a future version")
            color: Style.current.secondaryText
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
