import QtQuick 2.14
import QtQuick.Layouts 1.4

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.views 1.0
import shared.status 1.0

ColumnLayout {
    id: root
    objectName: "CommunityProfilePopupInviteFrindsPanel_ColumnLayout"

    property string headerTitle: ""

    property var rootStore
    property var contactsStore
    property var community

    property var pubKeys: ([])

    spacing: 0

    StyledText {
        id: headline
        text: qsTr("Contacts")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
    }

    SearchBox {
        id: filterInput
        placeholderText: qsTr("Search contacts")
        maximumHeight: 36
        topPadding: 0
        bottomPadding: 0
        Layout.fillWidth: true
        Layout.topMargin: Style.current.bigPadding
        Layout.bottomMargin: Style.current.padding
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
    }

    ExistingContacts {
        id: existingContacts

        rootStore: root.rootStore
        contactsStore: root.contactsStore
        communityId: root.community.id

        hideCommunityMembers: true
        showCheckbox: true
        filterText: filterInput.text
        pubKeys: root.pubKeys
        onContactClicked: function (contact) {
            if (!contact || typeof contact === "string") {
                return
            }
            const index = root.pubKeys.indexOf(contact.pubKey)
            const pubKeysCopy = Object.assign([], root.pubKeys)
            if (index === -1) {
                pubKeysCopy.push(contact.pubKey)
            } else {
                pubKeysCopy.splice(index, 1)
            }
            root.pubKeys = pubKeysCopy
        }
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Style.current.halfPadding
        Layout.rightMargin: Style.current.halfPadding
    }

    StatusModalDivider {
        Layout.fillWidth: true
    }

    StatusDescriptionListItem {
        Layout.fillWidth: true
        title: qsTr("Share community")
        subTitle: Utils.getCommunityShareLink(root.community.id)
        tooltip.text: qsTr("Copied!")
        asset.name: "copy"
        iconButton.onClicked: {
            let link = Utils.getCommunityShareLink(root.community.id)
            root.rootStore.copyToClipboard(link)
            tooltip.visible = !tooltip.visible
        }
    }
}
