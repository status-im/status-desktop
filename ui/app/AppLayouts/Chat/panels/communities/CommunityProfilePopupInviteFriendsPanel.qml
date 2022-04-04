import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Column {
    id: root

    property string headerTitle: ""

    property var rootStore
    property var contactsStore
    property var community
    property alias contactListSearch: contactFieldAndList

    StatusDescriptionListItem {
        title: qsTr("Share community")
        subTitle: `${Constants.communityLinkPrefix}${root.community && root.community.id.substring(0, 4)}...${root.community && root.community.id.substring(root.community.id.length -2)}`
        tooltip.text: qsTr("Copied!")
        icon.name: "copy"
        iconButton.onClicked: {
            let link = `${Constants.communityLinkPrefix}${root.community.id}`
            root.rootStore.copyToClipboard(link)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }

    StatusModalDivider {
        bottomPadding: Style.current.padding
    }

    StyledText {
        id: headline
        text: qsTr("Contacts")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
    }

    ContactsListAndSearch {
        id: contactFieldAndList
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 32
        contactsStore: root.contactsStore
        community: root.community
        showCheckbox: true
        hideCommunityMembers: true
        showSearch: false
        rootStore: root.rootStore
    }
}
