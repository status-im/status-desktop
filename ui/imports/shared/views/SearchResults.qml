import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1

import "../"
import "../status"
import "../panels"
import "./"

import StatusQ.Components 0.1

Item {
    id: root
    width: parent.width
    height: hasExistingContacts ? Style.dp(64) : 0

    property bool hasExistingContacts: false
    property bool showProfileNotFoundMessage: false
    property bool loading: false
    property string username: ""
    property string userAlias: ""
    property string pubKey: ""
    property string address: ""
    property bool resultClickable: true
    property bool addContactEnabled: true
    property bool isAddedContact: false

    signal resultClicked(string pubKey, bool isAddedContact, string username)
    signal addToContactsButtonClicked(string pubKey)

    function reset() {
        hasExistingContacts = false
        showProfileNotFoundMessage = false
        username = ""
        userAlias = ""
        pubKey = ""
        isAddedContact = false
    }

    function isContactAdded() {
        return root.pubKey != "" ? Utils.getContactDetailsAsJson(root.pubKey).isContact : false
    }

    onPubKeyChanged: {
        root.isAddedContact = root.isContactAdded()
    }

    StyledText {
        id: nonContactsLabel
        //% "Non contacts"
        text: qsTrId("non-contacts")
        anchors.top: parent.top
        color: Style.current.secondaryText
        font.pixelSize: Style.current.primaryTextFontSize
        visible: root.hasExistingContacts && (root.loading || root.pubKey !== "" || root.showProfileNotFoundMessage)
    }

    Loader {
        active: root.loading
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: Component {
            LoadingAnimation {
                width: Style.dp(18)
                height: Style.dp(18)
            }
        }
    }

    Rectangle {
        id: foundContact
        property bool hovered: false
        anchors.top: nonContactsLabel.visible ? nonContactsLabel.bottom : parent.top
        color: hovered ? Style.current.backgroundHover : Style.current.background
        radius: Style.current.radius
        width: parent.width
        height: Style.dp(64)
        visible: root.pubKey !== "" && !root.loading

        StatusSmartIdenticon {
            id: contactIdenticon
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            name: root.username
        }

        StyledText {
            id: ensUsername
            font.pixelSize: Style.dp(17)
            color: Style.current.textColor
            anchors.top: contactIdenticon.top
            anchors.left: contactIdenticon.right
            anchors.leftMargin: Style.current.padding
            text: root.username
        }

        StyledText {
            id: contactAlias
            font.pixelSize: Style.current.primaryTextFontSize
            color: Style.current.secondaryText
            anchors.top: ensUsername.bottom
            anchors.topMargin: Style.dp(2)
            anchors.left: ensUsername.left
            text: root.userAlias
        }

        MouseArea {
            cursorShape: root.resultClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: foundContact.hovered = true
            onExited: foundContact.hovered = false
            onClicked: {
                if (root.resultClickable) {
                    root.resultClicked(root.pubKey, root.isAddedContact, root.username)
                }
            }
        }

        StatusFlatRoundButton {
            id: addContactBtn
            width: Style.dp(32)
            height: Style.dp(32)
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            icon.width: Style.dp(24)
            icon.height: Style.dp(24)
            icon.name: "add-contact"
            backgroundHoverColor: Utils.setColorAlpha(Style.current.buttonHoveredBackgroundColor, 0.2)
            visible: addContactEnabled && !isAddedContact && !checkIcon.visible
            onClicked: {
                root.addToContactsButtonClicked(root.pubKey)
                mouse.accepted = false
            }
            onHoveredChanged: foundContact.hovered = addContactBtn.hovered
        }

        SVGImage {
            id: checkIcon
            source: Style.svg("check-2")
            width: Style.dp(19)
            height: Style.dp(19)
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding * 2
            anchors.verticalCenter: parent.verticalCenter
            visible: foundContact.hovered && isAddedContact
        }
    }

    StyledText {
        id: profileNotFoundMessage
        color: Style.current.secondaryText
        visible: root.showProfileNotFoundMessage
        font.pixelSize: Style.current.primaryTextFontSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        //% "No profile found"
        text: qsTrId("no-profile-found")
    }

}
