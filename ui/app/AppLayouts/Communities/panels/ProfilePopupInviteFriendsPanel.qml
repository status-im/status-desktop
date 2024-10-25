import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.views 1.0
import shared.status 1.0

import AppLayouts.stores 1.0 as AppLayoutStores
import AppLayouts.Profile.stores 1.0 as ProfileStores

ColumnLayout {
    id: root
    objectName: "CommunityProfilePopupInviteFrindsPanel_ColumnLayout"

    property string headerTitle: ""

    property AppLayoutStores.RootStore rootStore
    property ProfileStores.ContactsStore contactsStore
    property string communityId

    property var pubKeys: ([])

    spacing: 0

    StyledText {
        id: headline
        text: qsTr("Contacts")
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.secondaryText
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
    }

    SearchBox {
        id: filterInput
        placeholderText: qsTr("Search contacts")
        maximumHeight: 36
        topPadding: 0
        bottomPadding: 0
        Layout.fillWidth: true
        Layout.topMargin: Theme.bigPadding
        Layout.bottomMargin: Theme.padding
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
    }

    ExistingContacts {
        id: existingContacts

        rootStore: root.rootStore
        contactsStore: root.contactsStore
        communityId: root.communityId

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
        Layout.leftMargin: Theme.halfPadding
        Layout.rightMargin: Theme.halfPadding
    }

    StatusModalDivider {
        Layout.fillWidth: true
    }

    StatusDescriptionListItem {
        Layout.fillWidth: true
        title: qsTr("Share community")
        subTitle: Utils.getCommunityShareLink(root.communityId)
        tooltip.text: qsTr("Copied!")
        asset.name: "copy"
        iconButton.onClicked: {
            let link = Utils.getCommunityShareLink(root.communityId)
            ClipboardUtils.setText(link)
            tooltip.visible = !tooltip.visible
        }
    }
}
