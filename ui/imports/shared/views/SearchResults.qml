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
    height: hasExistingContacts ? 64 : 0

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

    function isUserAdded() {
        return root.pubKey != "" ? Utils.getContactDetailsAsJson(root.pubKey).isAdded : false
    }

    onPubKeyChanged: {
        root.isAddedContact = root.isUserAdded()
    }

    StyledText {
        id: nonContactsLabel
        text: qsTr("Non contacts")
        anchors.top: parent.top
        color: Style.current.secondaryText
        font.pixelSize: 15
        visible: root.hasExistingContacts && (root.loading || root.pubKey !== "" || root.showProfileNotFoundMessage)
    }

    Loader {
        active: root.loading
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: Component {
            LoadingAnimation {
                width: 18
                height: 18
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
        height: 64
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
            font.pixelSize: 17
            color: Style.current.textColor
            anchors.top: contactIdenticon.top
            anchors.left: contactIdenticon.right
            anchors.leftMargin: Style.current.padding
            text: root.username
        }

        StyledText {
            id: contactAlias
            font.pixelSize: 15
            color: Style.current.secondaryText
            anchors.top: ensUsername.bottom
            anchors.topMargin: 2
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
            width: 32
            height: 32
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            icon.width: 24
            icon.height: 24
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
            width: 19
            height: 19
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
        font.pixelSize: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("No profile found")
    }

}
