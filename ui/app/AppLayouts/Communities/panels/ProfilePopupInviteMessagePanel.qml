import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
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

    property var contactsModel
    property var pubKeys: ([])

    property alias inviteMessage: messageInput.text

    spacing: Theme.padding

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
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
    }

    StatusModalDivider {
        Layout.fillWidth: true
    }

    StyledText {
        text: qsTr("Invites will be sent to:")
        font.pixelSize: Theme.primaryTextFontSize
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
    }

    PickedContacts {
        id: existingContacts

        contactsModel: root.contactsModel
        pubKeys: root.pubKeys
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Theme.halfPadding
        Layout.rightMargin: Theme.halfPadding
    }
}
