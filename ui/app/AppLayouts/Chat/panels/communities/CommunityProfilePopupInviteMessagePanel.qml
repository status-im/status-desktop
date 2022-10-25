import QtQuick 2.14
import QtQuick.Layouts 1.4

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.views 1.0
import shared.status 1.0

ColumnLayout {
    id: root
    objectName: "CommunityProfilePopupInviteMessagePanel_ColumnLayout"

    property var pubKeys: ([])

    property var rootStore
    property var contactsStore

    property alias inviteMessage: messageInput.text

    spacing: Style.current.padding

    QtObject {
        id: d

        readonly property int maxMsgLength: 140
        readonly property int msgHeight: 108
    }

    StatusInput {
        id: messageInput
        input.edit.objectName: "CommunityProfilePopupInviteMessagePanel_MessageInput"
        label: qsTr("Invitation Message")
        charLimit: d.maxMsgLength
        placeholderText: qsTr("The message a contact will get with community invitation")
        input.multiline: true
        input.implicitHeight: d.msgHeight
        input.verticalAlignment: TextEdit.AlignTop
        Layout.minimumHeight: 150 // TODO: implicitHeight is not calculated well from input.implicitHeight
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
    }

    StatusModalDivider {
        Layout.fillWidth: true
    }

    StyledText {
        text: qsTr("Invites will be sent to:")
        font.pixelSize: Style.current.primaryTextFontSize
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
    }

    PickedContacts {
        id: existingContacts
        contactsStore: root.contactsStore
        pubKeys: root.pubKeys
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Style.current.halfPadding
        Layout.rightMargin: Style.current.halfPadding
    }
}
