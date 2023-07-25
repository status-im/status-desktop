import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0
import shared.views.profile 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.stores 1.0 as WalletNS

Pane {
    id: root

    property bool readOnly // inside settings/profile/preview

    property string publicKey: contactsStore.myPublicKey

    property var profileStore
    property var contactsStore
    property var walletStore: WalletNS.RootStore
    property var communitiesModel

    property QtObject dirtyValues: null
    property bool dirty: false

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
        readonly property string prettyEnsName: contactDetails.name
        readonly property string aliasName: contactDetails.alias
        readonly property string mainDisplayName: ProfileUtils.displayName(userNickName, prettyEnsName, userDisplayName, aliasName)
        readonly property string optionalDisplayName: ProfileUtils.displayName("", prettyEnsName, userDisplayName, aliasName)

        readonly property bool isContact: contactDetails.isContact
        readonly property bool isBlocked: contactDetails.isBlocked

        readonly property int contactRequestState: contactDetails.contactRequestState

        readonly property int outgoingVerificationStatus: contactDetails.verificationStatus
        readonly property int incomingVerificationStatus: contactDetails.incomingVerificationStatus

        readonly property bool isVerificationRequestSent:
            outgoingVerificationStatus !== Constants.verificationStatus.unverified &&
            outgoingVerificationStatus !== Constants.verificationStatus.verified &&
            outgoingVerificationStatus !== Constants.verificationStatus.trusted
        readonly property bool isVerificationRequestReceived: incomingVerificationStatus === Constants.verificationStatus.verifying ||
                                                              incomingVerificationStatus === Constants.verificationStatus.verified

        readonly property bool isTrusted: outgoingVerificationStatus === Constants.verificationStatus.trusted ||
                                          incomingVerificationStatus === Constants.verificationStatus.trusted
        readonly property bool isVerified: outgoingVerificationStatus === Constants.verificationStatus.verified

        readonly property string linkToProfile: root.contactsStore.getLinkToProfile(root.publicKey)

        readonly property var conns: Connections {
            target: root.contactsStore.myContactsModel ?? null

            function onItemChanged(pubKey) {
                if (pubKey === root.publicKey)
                    d.reload()
            }
        }

        // FIXME: use myContactsModel for identity verification
        readonly property var conns2: Connections {
            target: root.contactsStore.receivedContactRequestsModel ?? null

            function onItemChanged(pubKey) {
                if (pubKey === root.publicKey)
                    d.reload()
            }
        }

        readonly property var conns3: Connections {
            target: root.contactsStore.sentContactRequestsModel ?? null

            function onItemChanged(pubKey) {
                if (pubKey === root.publicKey)
                    d.reload()
            }
        }

        readonly property var conns4: Connections {
            target: Global

            function onContactRenamed(pubKey) {
                if (pubKey === root.publicKey)
                    d.reload()
            }
        }

        readonly property var timer: Timer {
            id: timer
        }
    }

    function reload() {
        d.reload()
    }

    Component {
        id: btnEditProfileComponent
        StatusButton {
            objectName: "editProfileButton"
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
                    root.contactsStore.acceptContactRequest(root.publicKey, "")
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
            objectName: "profileDialog_sendContactRequestButton"
            size: StatusButton.Size.Small
            text: qsTr("Send Contact Request")
            onClicked: {
                Global.openContactRequestPopup(root.publicKey, null)
            }
        }
    }

    Component {
        id: btnBlockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            type: StatusBaseButton.Type.Danger
            text: qsTr("Block User")
            onClicked: Global.blockContactRequested(root.publicKey, d.mainDisplayName)
        }
    }

    Component {
        id: btnUnblockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Unblock User")
            onClicked: Global.unblockContactRequested(root.publicKey, d.mainDisplayName)
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
        id: removeVerificationConfirmationDialog
        headerSettings.title: qsTr("Remove contact verification")
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
                name: root.dirty ? root.dirtyValues.displayName
                                 : d.mainDisplayName
                pubkey: root.publicKey
                image: root.dirty ? root.dirtyValues.profileLargeImage
                                  : d.contactDetails.largeImage
                interactive: false
                imageWidth: 80
                imageHeight: imageWidth
                ensVerified: d.contactDetails.ensVerified
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
                        text: root.dirty ? root.dirtyValues.displayName
                                         : d.mainDisplayName
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
                    text: "(%1)".arg(d.optionalDisplayName)
                    visible: !!d.userNickName
                }
                EmojiHash {
                    objectName: "ProfileDialog_userEmojiHash"
                    publicKey: root.publicKey
                }
                RowLayout {
                    StatusBaseText {
                        font.pixelSize: 12
                        color: Theme.palette.baseColor1
                        text: Utils.getElidedCompressedPk(root.publicKey)
                    }
                    StatusFlatButton {
                        size: StatusFlatButton.Size.Tiny
                        icon.name: "copy"
                        enabled: !d.timer.running

                        onClicked: {
                            copyKeyTooltip.text = qsTr("Copied")
                            root.profileStore.copyToClipboard(Utils.getCompressedPk(root.publicKey))
                            d.timer.setTimeout(function() {
                                copyKeyTooltip.text = qsTr("Copy Chat Key")
                            }, 1500);
                        }

                        StatusToolTip {
                            id: copyKeyTooltip
                            text: qsTr("Copy Chat Key")
                            visible: parent.hovered || d.timer.running
                        }
                    }
                }
            }

            Loader {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: menuButton.visible ? menuButton.height : -1
                sourceComponent: {
                    // current user
                    if (d.isCurrentUser)
                        return btnEditProfileComponent

                    // blocked contact
                    if (d.isBlocked)
                        return btnUnblockUserComponent

                    // block user
                    if (d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy)
                        return btnBlockUserComponent

                    // depend on contactRequestState
                    switch (d.contactRequestState) {
                    case Constants.ContactRequestState.Sent:
                        return txtPendingContactRequestComponent
                    case Constants.ContactRequestState.Received:
                        return btnAcceptContactRequestComponent
                    case Constants.ContactRequestState.Mutual: {
                        if (d.incomingVerificationStatus === Constants.verificationStatus.declined) {
                            return btnBlockUserComponent
                        } else if (!d.isTrusted && d.isVerificationRequestReceived) {
                            return btnRespondToIdRequestComponent
                        }
                        return btnSendMessageComponent
                    }
                    case Constants.ContactRequestState.None:
                    case Constants.ContactRequestState.Dismissed:
                        return btnSendContactRequestComponent
                    default:
                        console.warn("!!! UNHANDLED CONTACT ACTION BUTTON; PUBKEY", root.publicKey)
                        return null
                    }
                }
            }

            StatusFlatButton {
                id: menuButton
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: height

                visible: !d.isCurrentUser
                horizontalPadding: 6
                verticalPadding: 6
                icon.name: "more"
                icon.color: Theme.palette.directColor1
                highlighted: moreMenu.opened
                onClicked: moreMenu.popup(-moreMenu.width + width, height + 4)

                StatusMenu {
                    id: moreMenu

                    SendContactRequestMenuItem {
                        enabled: !d.isContact && !d.isBlocked && d.contactRequestState !== Constants.ContactRequestState.Sent &&
                                 d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy // we have an action button otherwise
                        onTriggered: {
                            moreMenu.close()
                            Global.openContactRequestPopup(root.publicKey, null)
                        }
                    }
                    StatusAction {
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
                    StatusAction {
                        text: qsTr("ID Request Pending...")
                        icon.name: "checkmark-circle"
                        enabled: d.isContact && !d.isBlocked && !d.isTrusted && d.isVerificationRequestSent
                        onTriggered: {
                            moreMenu.close()
                            Global.openOutgoingIDRequestPopup(root.publicKey,
                                                              popup => popup.closed.connect(d.reload))
                        }
                    }
                    StatusAction {
                        text: qsTr("Rename")
                        icon.name: "edit_pencil"
                        onTriggered: {
                            moreMenu.close()
                            Global.openNicknamePopupRequested(root.publicKey, d.userNickName,
                                                              "%1 (%2)".arg(d.optionalDisplayName).arg(Utils.getElidedCompressedPk(root.publicKey)))
                        }
                    }
                    StatusAction {
                        text: qsTr("Copy Link to Profile")
                        icon.name: "copy"
                        onTriggered: {
                            moreMenu.close()
                            root.profileStore.copyToClipboard(d.linkToProfile)
                        }
                    }
                    StatusAction {
                        text: qsTr("Unblock User")
                        icon.name: "remove-circle"
                        enabled: d.isBlocked
                        onTriggered: {
                            moreMenu.close()
                            Global.unblockContactRequested(root.publicKey, d.mainDisplayName)
                        }
                    }
                    StatusMenuSeparator {}
                    StatusAction {
                        text: qsTr("Mark as Untrustworthy")
                        icon.name: "warning"
                        type: StatusAction.Type.Danger
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
                    StatusAction {
                        text: qsTr("Remove Untrustworthy Mark")
                        icon.name: "warning"
                        enabled: d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy
                        onTriggered: {
                            moreMenu.close()
                            root.contactsStore.removeTrustStatus(root.publicKey)
                            d.reload()
                        }
                    }
                    StatusAction {
                        text: qsTr("Remove Identity Verification")
                        icon.name: "warning"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && d.isTrusted
                        onTriggered: {
                            moreMenu.close()
                            removeVerificationConfirmationDialog.open()
                        }
                    }
                    StatusAction {
                        text: qsTr("Remove Contact")
                        icon.name: "remove-contact"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && !d.isBlocked && d.contactRequestState !== Constants.ContactRequestState.Sent
                        onTriggered: {
                            Global.removeContactRequested(root.mainDisplayName, root.publicKey);
                            moreMenu.close();
                        }
                    }
                    StatusAction {
                        text: qsTr("Block User")
                        icon.name: "cancel"
                        type: StatusAction.Type.Danger
                        enabled: !d.isBlocked
                        onTriggered: {
                            moreMenu.close()
                            Global.blockContactRequested(root.publicKey, d.mainDisplayName)
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
            padding: 0
            contentWidth: availableWidth

            ColumnLayout {
                width: scrollView.availableWidth
                spacing: 20

                ProfileBioSocialsPanel {
                    Layout.fillWidth: true
                    Layout.leftMargin: column.anchors.leftMargin + Style.current.halfPadding
                    Layout.rightMargin: column.anchors.rightMargin + Style.current.halfPadding
                    bio: root.dirty ? root.dirtyValues.bio : d.contactDetails.bio
                    userSocialLinksJson: root.readOnly ? root.profileStore.temporarySocialLinksJson
                                                       : d.contactDetails.socialLinks
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
                        leftPadding: Style.current.padding
                        rightPadding: Style.current.halfPadding
                        topPadding: 0
                        bottomPadding: 0
                        placeholder.rightPadding: Style.current.halfPadding
                        placeholderText: d.linkToProfile
                        placeholderTextColor: Theme.palette.directColor1
                        edit.readOnly: true
                        rightComponent: StatusButton {
                            id: copyLinkBtn
                            anchors.verticalCenter: parent.verticalCenter
                            borderColor: Theme.palette.primaryColor1
                            size: StatusBaseButton.Size.Tiny
                            text: qsTr("Copy")
                            onClicked: {
                                text = qsTr("Copied")
                                root.profileStore.copyToClipboard(d.linkToProfile)
                                d.timer.setTimeout(function() {
                                    copyLinkBtn.text = qsTr("Copy")
                                }, 2000);
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
                        leftPadding: Style.current.padding
                        rightPadding: Style.current.halfPadding
                        topPadding: 0
                        bottomPadding: 0
                        edit.readOnly: true
                        leftComponent: EmojiHash {
                            publicKey: root.publicKey
                            oneRow: !root.readOnly
                        }
                        rightComponent: StatusButton {
                            id: copyHashBtn
                            anchors.verticalCenter: parent.verticalCenter
                            borderColor: Theme.palette.primaryColor1
                            size: StatusBaseButton.Size.Tiny
                            text: qsTr("Copy")
                            onClicked: {
                                root.profileStore.copyToClipboard(Utils.getEmojiHashAsJson(root.publicKey).join("").toString())
                                text = qsTr("Copied")
                                d.timer.setTimeout(function() {
                                    copyHashBtn.text = qsTr("Copy")
                                }, 2000);
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
                            source: root.profileStore.getQrCodeSource(Utils.getCompressedPk(root.profileStore.pubkey))
                        }
                    }
                }

                StatusTabBar {
                    id: showcaseTabBar
                    Layout.fillWidth: true
                    Layout.leftMargin: column.anchors.leftMargin
                    Layout.rightMargin: column.anchors.rightMargin
                    bottomPadding: -4
                    StatusTabButton {
                        leftPadding: 0
                        width: implicitWidth
                        text: qsTr("Communities")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Accounts")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Collectibles")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Assets")
                    }
                }

                // Profile Showcase
                ProfileShowcaseView {
                    Layout.fillWidth: true
                    Layout.topMargin: -column.spacing
                    Layout.preferredHeight: 300

                    currentTabIndex: showcaseTabBar.currentIndex
                    isCurrentUser: d.isCurrentUser
                    mainDisplayName: d.mainDisplayName
                    readOnly: root.readOnly
                    profileStore: root.profileStore
                    walletStore: root.walletStore
                    communitiesModel: root.communitiesModel

                    onCloseRequested: root.closeRequested()
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
