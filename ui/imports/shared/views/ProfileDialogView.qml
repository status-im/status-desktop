import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0

Pane {
    id: root

    property bool readOnly

    property string publicKey: contactsStore.myPublicKey

    property var profileStore
    property var contactsStore

    signal closeRequested()

    padding: 0
    topPadding: 40

    background: StatusDialogBackground {
        id: background
    }

    QtObject {
        id: d
        property var contactDetails: Utils.getContactDetailsAsJson(root.publicKey)

        function reload() {
            contactDetails = Utils.getContactDetailsAsJson(root.publicKey)
        }

        readonly property bool isCurrentUser: root.profileStore.pubkey === root.publicKey
        readonly property string userDisplayName: contactDetails.displayName
        readonly property string userNickName: contactDetails.localNickname
        readonly property string prettyEnsName: '@' + Utils.removeStatusEns(contactDetails.name)
        readonly property bool isContact: contactDetails.isContact
        readonly property bool isBlocked: contactDetails.isBlocked

        readonly property bool isContactRequestSent: contactDetails.isAdded
        readonly property bool isContactRequestReceived: contactDetails.hasAddedUs

        readonly property int outgoingVerificationStatus: contactDetails.verificationStatus
        readonly property int incomingVerificationStatus: contactDetails.incomingVerificationStatus

        readonly property bool isVerificationRequestSent:
            outgoingVerificationStatus !== Constants.verificationStatus.unverified &&
            outgoingVerificationStatus !== Constants.verificationStatus.verified &&
            outgoingVerificationStatus !== Constants.verificationStatus.trusted
        readonly property bool isVerificationRequestReceived: d.isCurrentUser ? false : root.contactsStore.hasReceivedVerificationRequestFrom(root.publicKey)

        readonly property bool isTrusted: outgoingVerificationStatus === Constants.verificationStatus.trusted ||
                                          incomingVerificationStatus === Constants.verificationStatus.trusted
        readonly property bool isVerified: outgoingVerificationStatus === Constants.verificationStatus.verified

        readonly property string linkToProfile: {
            let user = ""
            if (d.isCurrentUser)
                user = root.profileStore.ensName
            else
                user = contactDetails.name
            if (!user)
                user = Utils.getCompressedPk(root.publicKey)
            return Constants.userLinkPrefix + user
        }

        readonly property var conns: Connections {
            target: Global
            function onNickNameChanged(publicKey, nickname) {
                if (publicKey === root.publicKey) d.reload()
            }
            function onContactBlocked(publicKey) {
                if (publicKey === root.publicKey) d.reload()
            }
            function onContactUnblocked(publicKey) {
                if (publicKey === root.publicKey) d.reload()
            }
        }
    }

    function reload() {
        d.reload()
    }

    Component {
        id: btnEditProfileComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Edit Profile")
            enabled: !root.readOnly
            onClicked: {
                Global.changeAppSectionBySectionType(Constants.appSection.profile)
                root.closeRequested()
            }
        }
    }

    Component {
        id: btnSendMessageComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Send Message")
            onClicked: {
                root.contactsStore.joinPrivateChat(root.publicKey)
                root.closeRequested()
            }
        }
    }

    Component {
        id: btnAcceptContactRequestComponent
        ColumnLayout {
            spacing: Style.current.halfPadding

            StatusBaseText {
                color: Theme.palette.baseColor1
                font.pixelSize: 13
                text: qsTr("Respond to contact request")
            }

            AcceptRejectOptionsButtonsPanel {
                menuButton.visible: false
                onAcceptClicked: {
                    root.contactsStore.acceptContactRequest(root.publicKey)
                    d.reload()
                }
                onDeclineClicked: {
                    root.contactsStore.dismissContactRequest(root.publicKey)
                    d.reload()
                }
            }
        }
    }

    Component {
        id: btnSendContactRequestComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Send Contact Request")
            onClicked: {
                Global.openContactRequestPopup(root.publicKey,
                                               popup => popup.accepted.connect(d.reload))
            }
        }
    }

    Component {
        id: btnBlockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            type: StatusBaseButton.Type.Danger
            text: qsTr("Block User")
            onClicked: Global.blockContactRequested(root.publicKey, d.userDisplayName)
        }
    }

    Component {
        id: btnUnblockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Unblock User")
            onClicked: Global.unblockContactRequested(root.publicKey, d.userDisplayName)
        }
    }

    Component {
        id: txtPendingContactRequestComponent
        StatusBaseText {
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Theme.palette.baseColor1
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Contact Request Pending...")
        }
    }

    Component {
        id: txtRejectedContactRequestComponent
        StatusBaseText {
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Theme.palette.baseColor1
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Contact Request Rejected")
        }
    }

    Component {
        id: btnRespondToIdRequestComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Respond to ID Request")
            onClicked: {
                Global.openIncomingIDRequestPopup(root.publicKey,
                                                  popup => popup.closed.connect(d.reload))
            }
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        header.title: qsTr("Remove contact '%1'").arg(d.userDisplayName)
        confirmationText: qsTr("This will remove the user as a contact. Please confirm.")
        onConfirmButtonClicked: {
            root.contactsStore.removeContact(root.publicKey)
            close()
            d.reload()
        }
    }

    ConfirmationDialog {
        id: removeVerificationConfirmationDialog
        header.title: qsTr("Remove contact verification")
        confirmationText: qsTr("This will remove the contact's verified status. Please confirm.")
        onConfirmButtonClicked: {
            root.contactsStore.removeTrustStatus(root.publicKey)
            close()
            d.reload()
        }
    }

    ColumnLayout {
        id: column
        spacing: 20
        anchors {
            fill: parent
            leftMargin: Style.current.bigPadding
            rightMargin: Style.current.bigPadding
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.halfPadding

            UserImage {
                Layout.alignment: Qt.AlignTop
                objectName: "ProfileDialog_userImage"
                name: d.userDisplayName
                pubkey: root.publicKey
                image: d.contactDetails.largeImage
                interactive: false
                imageWidth: 80
                imageHeight: imageWidth
                showRing: !d.contactDetails.ensVerified
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.alignment: Qt.AlignTop
                spacing: 4
                Item {
                    id: contactRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    StatusBaseText {
                        id: contactName
                        anchors.left: parent.left
                        width: Math.min(implicitWidth, contactRow.width - verificationIcons.width - verificationIcons.anchors.leftMargin)
                        objectName: "ProfileDialog_displayName"
                        font.bold: true
                        font.pixelSize: 22
                        elide: Text.ElideRight
                        text: d.userDisplayName
                    }
                    StatusContactVerificationIcons {
                        id: verificationIcons
                        anchors.left: contactName.right
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.verticalCenter: contactName.verticalCenter
                        objectName: "ProfileDialog_userVerificationIcons"
                        visible: !d.isCurrentUser
                        isContact: d.isContact
                        trustIndicator: d.contactDetails.trustStatus
                        tiny: false
                    }
                }
                StatusBaseText {
                    id: contactSecondaryName
                    font.pixelSize: 12
                    color: Theme.palette.baseColor1
                    text: {
                        let result = ""
                        if (d.userNickName) {
                            if (d.contactDetails.ensVerified && d.contactDetails.name)
                                result = d.prettyEnsName
                            else
                                result = d.contactDetails.optionalName // original display name
                        }
                        if (result)
                            return "(%1)".arg(result)
                        return ""
                    }
                    visible: text
                }
                EmojiHash {
                    objectName: "ProfileDialog_userEmojiHash"
                    publicKey: root.publicKey
                }
            }

            Loader {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: menuButton.visible ? menuButton.height : -1
                sourceComponent: {
                    // current user
                    if (d.isCurrentUser)
                        return btnEditProfileComponent

                    // contact request, outgoing, rejected
                    if (!d.isContact && d.isContactRequestSent && d.outgoingVerificationStatus === Constants.verificationStatus.declined)
                        return txtRejectedContactRequestComponent
                    // contact request, outgoing, pending
                    if (!d.isContact && d.isContactRequestSent)
                        return txtPendingContactRequestComponent

                    // contact request, incoming, pending
                    if (!d.isContact && d.isContactRequestReceived)
                        return btnAcceptContactRequestComponent

                    // contact request, incoming, rejected
                    if (d.isContactRequestSent && d.incomingVerificationStatus === Constants.verificationStatus.declined)
                        return btnBlockUserComponent

                    // verified contact request, incoming, pending
                    if (d.isContact && !d.isTrusted && d.isVerificationRequestReceived)
                        return btnRespondToIdRequestComponent

                    // block user
                    if (!d.isContact && !d.isBlocked &&
                            (d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy || d.outgoingVerificationStatus === Constants.verificationStatus.declined))
                        return btnBlockUserComponent

                    // send contact request
                    if (!d.isContact && !d.isBlocked && !d.isContactRequestSent)
                        return btnSendContactRequestComponent

                    // blocked contact
                    if (d.isBlocked)
                        return btnUnblockUserComponent

                    // send message
                    if (d.isContact && !d.isBlocked)
                        return btnSendMessageComponent

                    console.warn("!!! UNHANDLED CONTACT ACTION BUTTON; PUBKEY", root.publicKey)
                }
            }

            StatusFlatButton {
                id: menuButton
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: height

                visible: !d.isCurrentUser
                size: StatusBaseButton.Size.Small
                horizontalPadding: 6
                verticalPadding: 6
                icon.name: "more"
                icon.color: Theme.palette.directColor1
                highlighted: moreMenu.opened
                onClicked: moreMenu.popup(-moreMenu.width + width, height + 4)

                StatusPopupMenu {
                    id: moreMenu
                    width: 230

                    SendContactRequestMenuItem {
                        enabled: !d.isContact && !d.isBlocked && !d.isContactRequestSent && !d.contactDetails.removed &&
                                 d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy // we have an action button otherwise
                        onTriggered: {
                            moreMenu.close()
                            Global.openContactRequestPopup(root.publicKey,
                                                           popup => popup.closed.connect(d.reload))
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Verify Identity")
                        icon.name: "checkmark-circle"
                        enabled: d.isContact && !d.isBlocked &&
                                 d.outgoingVerificationStatus === Constants.verificationStatus.unverified &&
                                 !d.isVerificationRequestReceived
                        onTriggered: {
                            moreMenu.close()
                            Global.openSendIDRequestPopup(root.publicKey,
                                                          popup => popup.accepted.connect(d.reload))
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("ID Request Pending...")
                        icon.name: "checkmark-circle"
                        enabled: d.isContact && !d.isBlocked && !d.isTrusted && d.isVerificationRequestSent
                        onTriggered: {
                            moreMenu.close()
                            Global.openOutgoingIDRequestPopup(root.publicKey,
                                                              popup => popup.closed.connect(d.reload))
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Rename")
                        icon.name: "edit_pencil"
                        onTriggered: {
                            moreMenu.close()
                            Global.openNicknamePopupRequested(root.publicKey, d.userNickName,
                                                              "%1 (%2)".arg(d.userDisplayName).arg(Utils.getElidedCompressedPk(root.publicKey)))
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Reverse Contact Rejection")
                        icon.name: "refresh"
                        enabled: d.contactDetails.removed
                        onTriggered: {
                            moreMenu.close()
                            root.contactsStore.removeContactRequestRejection(root.publicKey)
                            d.reload()
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Copy Link to Profile")
                        icon.name: "copy"
                        onTriggered: {
                            moreMenu.close()
                            root.profileStore.copyToClipboard(d.linkToProfile)
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Unblock User")
                        icon.name: "remove-circle"
                        enabled: d.isBlocked
                        onTriggered: {
                            moreMenu.close()
                            Global.unblockContactRequested(root.publicKey, d.userDisplayName)
                        }
                    }
                    StatusMenuSeparator {}
                    StatusMenuItem {
                        text: qsTr("Mark as Untrustworthy")
                        icon.name: "warning"
                        type: StatusMenuItem.Type.Danger
                        enabled: d.contactDetails.trustStatus === Constants.trustStatus.unknown
                        onTriggered: {
                            moreMenu.close()
                            if (d.isContact && !d.isTrusted && d.isVerificationRequestReceived)
                                root.contactsStore.verifiedUntrustworthy(root.publicKey)
                            else
                                root.contactsStore.markUntrustworthy(root.publicKey)
                            d.reload()
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Remove Untrustworthy Mark")
                        icon.name: "warning"
                        enabled: d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy
                        onTriggered: {
                            moreMenu.close()
                            root.contactsStore.removeTrustStatus(root.publicKey)
                            d.reload()
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Remove Identity Verification")
                        icon.name: "warning"
                        type: StatusMenuItem.Type.Danger
                        enabled: d.isContact && d.isTrusted
                        onTriggered: {
                            moreMenu.close()
                            removeVerificationConfirmationDialog.open()
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Remove Contact")
                        icon.name: "remove-contact"
                        type: StatusMenuItem.Type.Danger
                        enabled: d.isContact && !d.isBlocked
                        onTriggered: {
                            moreMenu.close()
                            removeContactConfirmationDialog.open()
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Cancel Contact Request")
                        icon.name: "cancel"
                        type: StatusMenuItem.Type.Danger
                        enabled: !d.isContact && d.isContactRequestSent && !d.contactDetails.removed
                        onTriggered: {
                            moreMenu.close()
                            root.contactsStore.removeContact(root.publicKey)
                            d.reload()
                        }
                    }
                    StatusMenuItem {
                        text: qsTr("Block User")
                        icon.name: "cancel"
                        type: StatusMenuItem.Type.Danger
                        enabled: !d.isBlocked
                        onTriggered: {
                            moreMenu.close()
                            Global.blockContactRequested(root.publicKey, d.userDisplayName)
                        }
                    }
                }
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
            Layout.leftMargin: -column.anchors.leftMargin
            Layout.rightMargin: -column.anchors.rightMargin
            Layout.topMargin: -column.spacing
            Layout.bottomMargin: -column.spacing
            opacity: scrollView.atYBeginning ? 0 : 1
            Behavior on opacity { OpacityAnimator {} }
        }

        StatusScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: -column.anchors.leftMargin
            Layout.rightMargin: -column.anchors.rightMargin
            Layout.topMargin: -column.spacing
            padding: 0

            ColumnLayout {
                width: scrollView.width
                spacing: 20

                ProfileBioSocialsPanel {
                    Layout.fillWidth: true
                    Layout.leftMargin: column.anchors.leftMargin + Style.current.halfPadding
                    Layout.rightMargin: column.anchors.rightMargin + Style.current.halfPadding
                    bio: d.contactDetails.bio
                    userSocialLinksJson: d.contactDetails.socialLinks
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: column.anchors.leftMargin
                    Layout.rightMargin: column.anchors.rightMargin
                    flow: GridLayout.TopToBottom
                    rowSpacing: Style.current.halfPadding
                    columnSpacing: Style.current.bigPadding
                    visible: d.isCurrentUser
                    enabled: visible
                    columns: 2
                    rows: 4

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: qsTr("Link to Profile")
                        font.pixelSize: 13
                    }

                    StatusBaseInput {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        leftPadding: 14
                        rightPadding: Style.current.halfPadding
                        topPadding: 0
                        bottomPadding: 0
                        placeholder.rightPadding: Style.current.halfPadding
                        placeholderText: d.linkToProfile
                        placeholderTextColor: Theme.palette.directColor1
                        edit.readOnly: true
                        rightComponent: StatusButton {
                            anchors.verticalCenter: parent.verticalCenter
                            borderColor: Theme.palette.primaryColor1
                            size: StatusBaseButton.Size.Tiny
                            text: qsTr("Copy")
                            onClicked: {
                                text = qsTr("Copied")
                                root.profileStore.copyToClipboard(d.linkToProfile)
                            }
                        }
                    }

                    StatusBaseText {
                        Layout.fillWidth: true
                        Layout.topMargin: Style.current.smallPadding
                        text: qsTr("Emoji Hash")
                        font.pixelSize: 13
                    }

                    StatusBaseInput {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        leftPadding: 14
                        rightPadding: Style.current.halfPadding
                        topPadding: 0
                        bottomPadding: 0
                        edit.readOnly: true
                        leftComponent: EmojiHash {
                            publicKey: root.publicKey
                            oneRow: !root.readOnly
                        }
                        rightComponent: StatusButton {
                            anchors.verticalCenter: parent.verticalCenter
                            borderColor: Theme.palette.primaryColor1
                            size: StatusBaseButton.Size.Tiny
                            text: qsTr("Copy")
                            onClicked: {
                                root.profileStore.copyToClipboard(Utils.getEmojiHashAsJson(root.publicKey).join("").toString())
                                text = qsTr("Copied")
                            }
                        }
                    }

                    Rectangle {
                        Layout.rowSpan: 4
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        Layout.alignment: Qt.AlignCenter
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.palette.baseColor2
                        radius: Style.current.halfPadding

                        Image {
                            anchors.centerIn: parent
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            width: 170
                            height: width
                            mipmap: true
                            smooth: false
                            source: root.profileStore.getQrCodeSource(root.profileStore.pubkey)
                        }
                    }
                }

                StatusTabBar {
                    Layout.fillWidth: true
                    Layout.leftMargin: column.anchors.leftMargin
                    Layout.rightMargin: column.anchors.rightMargin
                    bottomPadding: -4

                    StatusTabButton {
                        leftPadding: 0
                        width: implicitWidth
                        text: qsTr("Tokens")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("NFTs")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Communities")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Accounts")
                    }
                }

                StatusDialogBackground {
                    Layout.fillWidth: true
                    Layout.topMargin: -column.spacing
                    Layout.preferredHeight: 300
                    color: Theme.palette.baseColor4

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.radius
                        color: parent.color
                    }

                    StatusBaseText {
                        anchors.centerIn: parent
                        color: Theme.palette.baseColor1
                        text: qsTr("More content to appear here soon...")
                    }
                }
            }
        }
    }

    layer.enabled: !root.readOnly // profile preview has its own layer.effect
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            anchors.centerIn: parent
            width: column.width
            height: column.height
            radius: background.radius
        }
    }
}
