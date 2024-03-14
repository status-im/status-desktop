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
    property var networkConnectionStore

    property var dirtyValues: ({})
    property bool dirty: false

    signal closeRequested()

    padding: 0
    topPadding: 32

    background: StatusDialogBackground {
        id: background
    }

    QtObject {
        id: d
        property var contactDetails: Utils.getContactDetailsAsJson(root.publicKey, !isCurrentUser, !isCurrentUser, true)

        function reload() {
            contactDetails = Utils.getContactDetailsAsJson(root.publicKey, !isCurrentUser, !isCurrentUser, true)
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
        readonly property bool isLocallyTrusted: contactDetails.trustStatus === Constants.trustStatus.trusted

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
            interactive: !root.readOnly
            tooltip.text: interactive ? "" : qsTr("Not available in preview mode")
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
        StatusButton {
            objectName: "profileDialog_reviewContactRequestButton"
            size: StatusButton.Size.Small
            text: qsTr("Review contact request")
            onClicked: Global.openReviewContactRequestPopup(root.publicKey, d.contactDetails,
                                                            popup => popup.closed.connect(d.reload))
        }
    }

    Component {
        id: btnSendContactRequestComponent
        StatusButton {
            objectName: "profileDialog_sendContactRequestButton"
            size: StatusButton.Size.Small
            text: qsTr("Send contact request")
            onClicked: Global.openContactRequestPopup(root.publicKey, d.contactDetails,
                                                      popup => popup.accepted.connect(d.reload))
        }
    }

    Component {
        id: btnBlockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            type: StatusBaseButton.Type.Danger
            text: qsTr("Block user")
            onClicked: Global.blockContactRequested(root.publicKey, d.contactDetails)
        }
    }

    Component {
        id: btnUnblockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            text: qsTr("Unblock user")
            onClicked: Global.unblockContactRequested(root.publicKey, d.contactDetails)
        }
    }

    Component {
        id: txtPendingContactRequestComponent
        RowLayout {
            StatusIcon {
                icon: "history"
                width: 16
                height: width
                color: Theme.palette.baseColor1
            }
            StatusBaseText {
                font.pixelSize: 13
                font.weight: Font.Medium
                color: Theme.palette.baseColor1
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Contact Request Pending")
            }
        }
    }

    Component {
        id: btnReplyToIdRequestComponent
        StatusFlatButton {
            size: StatusButton.Size.Small
            text: qsTr("Reply to ID verification request")
            objectName: "respondToIDRequest_StatusItem"
            icon.name: "checkmark-circle"
            onClicked: Global.openIncomingIDRequestPopup(root.publicKey, d.contactDetails,
                                                         popup => popup.closed.connect(d.reload))
        }
    }

    Component {
        id: btnRequestIDVerification
        StatusFlatButton {
            size: StatusButton.Size.Small
            text: qsTr("Request ID verification")
            objectName: "requestIDVerification_StatusItem"
            icon.name: "checkmark-circle"
            onClicked: Global.openSendIDRequestPopup(root.publicKey, d.contactDetails,
                                                     popup => popup.accepted.connect(d.reload))
        }
    }

    Component {
        id: btnReviewIDVerificationReply
        StatusFlatButton {
            size: StatusButton.Size.Small
            text: d.incomingVerificationStatus !== Constants.verificationStatus.verified ? qsTr("ID verification pending")
                                                                                         : qsTr("Review ID verification reply")
            icon.name: d.incomingVerificationStatus !== Constants.verificationStatus.verified ? "history" : "checkmark-circle"
            onClicked: Global.openOutgoingIDRequestPopup(root.publicKey, d.contactDetails,
                                                         popup => popup.closed.connect(d.reload))
        }
    }

    Component {
        id: btnShareProfile
        StatusFlatButton {
            size: StatusButton.Size.Small
            text: qsTr("Share Profile")
            onClicked: Global.openPopup(shareProfileCmp)
        }
    }

    Component {
        id: shareProfileCmp
        ShareProfileDialog {
            destroyOnClose: true
            title: d.isCurrentUser ? qsTr("Share your profile") : qsTr("%1's profile").arg(d.mainDisplayName)
            publicKey: root.publicKey
            linkToProfile: d.linkToProfile
            qrCode: root.profileStore.getQrCodeSource(linkToProfile)
            displayName: userImage.name
            largeImage: userImage.image
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
                id: userImage
                Layout.alignment: Qt.AlignTop
                objectName: "ProfileDialog_userImage"
                name: root.dirty ? root.dirtyValues.displayName
                                 : d.mainDisplayName
                pubkey: root.publicKey
                image: root.dirty ? root.dirtyValues.profileLargeImage
                                  : Utils.addTimestampToURL(d.contactDetails.largeImage)
                interactive: false
                imageWidth: 90
                imageHeight: imageWidth
                ensVerified: d.contactDetails.ensVerified

                Binding on onlineStatus {
                    value: d.contactDetails.onlineStatus
                    when: !d.isCurrentUser
                }
            }

            Item { Layout.fillWidth: true }

            // secondary action button
            Loader {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: menuButton.visible ? menuButton.height : -1
                sourceComponent: {
                    if (d.isCurrentUser && !root.readOnly)
                        return btnShareProfile

                    if (d.isContact && !(d.isTrusted || d.isLocallyTrusted) && !d.isBlocked) {
                        if (d.isVerificationRequestSent)
                            return btnReviewIDVerificationReply
                        else if (d.isVerificationRequestReceived)
                            return btnReplyToIdRequestComponent
                        else if (d.outgoingVerificationStatus === Constants.verificationStatus.unverified)
                            return btnRequestIDVerification
                    }
                }
            }

            // primary action button
            Loader {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: menuButton.visible ? menuButton.height : -1

                sourceComponent: {
                    // current user
                    if (d.isCurrentUser)
                        return btnEditProfileComponent

                    // blocked user
                    if (d.isBlocked)
                        return btnUnblockUserComponent

                    // accept incoming CR
                    if (d.contactRequestState === Constants.ContactRequestState.Received)
                        return btnAcceptContactRequestComponent

                    // mutual contact
                    if (d.isContact || d.contactRequestState === Constants.ContactRequestState.Mutual)
                        return btnSendMessageComponent

                    // depend on contactRequestState
                    switch (d.contactRequestState) {
                    case Constants.ContactRequestState.Sent:
                        return txtPendingContactRequestComponent
                    case Constants.ContactRequestState.Received:
                        break // handled above
                    case Constants.ContactRequestState.Mutual: {
                        if (d.outgoingVerificationStatus === Constants.verificationStatus.declined) {
                            return btnBlockUserComponent
                        }
                        break
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
                            Global.openContactRequestPopup(root.publicKey, d.contactDetails, null)
                        }
                    }
                    StatusAction {
                        text: qsTr("Mark as ID verified")
                        icon.name: "checkmark-circle"
                        enabled: d.isContact && !d.isBlocked && !(d.isTrusted || d.isLocallyTrusted)
                        onTriggered: Global.openMarkAsIDVerifiedPopup(root.publicKey, d.contactDetails,
                                                                      popup => popup.accepted.connect(d.reload))
                    }
                    StatusAction {
                        text: d.userNickName ? qsTr("Edit nickname") : qsTr("Add nickname")
                        icon.name: "edit_pencil"
                        onTriggered: {
                            Global.openNicknamePopupRequested(root.publicKey, d.contactDetails,
                                                              popup => popup.closed.connect(d.reload))
                        }
                    }
                    StatusAction {
                        text: qsTr("Show QR code")
                        icon.name: "qr"
                        enabled: !d.isCurrentUser
                        onTriggered: {
                            Global.openPopup(shareProfileCmp)
                        }
                    }
                    StatusAction {
                        text: qsTr("Copy link to profile")
                        icon.name: "copy"
                        onTriggered: {
                            root.profileStore.copyToClipboard(d.linkToProfile)
                        }
                    }
                    StatusMenuSeparator {}
                    StatusAction {
                        text: qsTr("Remove ID verification")
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && (d.isTrusted || d.isLocallyTrusted)
                        onTriggered: Global.openRemoveIDVerificationDialog(root.publicKey, d.contactDetails,
                                                                           popup => popup.accepted.connect(d.reload))
                    }
                    StatusAction {
                        text: qsTr("Remove nickname")
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                        enabled: !d.isCurrentUser && !!d.contactDetails.localNickname
                        onTriggered: root.contactsStore.changeContactNickname(root.publicKey, "", d.optionalDisplayName, true)
                    }
                    StatusAction {
                        text: qsTr("Mark as untrusted")
                        icon.name: "warning"
                        type: StatusAction.Type.Danger
                        enabled: d.contactDetails.trustStatus !== Constants.trustStatus.untrustworthy && !d.isBlocked
                        onTriggered: {
                            Global.markAsUntrustedRequested(root.publicKey, d.contactDetails)
                        }
                    }
                    StatusAction {
                        text: qsTr("Cancel ID verification request")
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && !d.isBlocked && d.isVerificationRequestSent
                        onTriggered: root.contactsStore.cancelVerificationRequest(root.publicKey)
                    }
                    StatusAction {
                        text: qsTr("Remove untrusted mark")
                        icon.name: "warning"
                        type: StatusAction.Type.Danger
                        enabled: d.contactDetails.trustStatus === Constants.trustStatus.untrustworthy && !d.isBlocked
                        onTriggered: {
                            root.contactsStore.removeTrustStatus(root.publicKey)
                        }
                    }
                    StatusAction {
                        text: qsTr("Remove contact")
                        icon.name: "remove-contact"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && !d.isBlocked && d.contactRequestState !== Constants.ContactRequestState.Sent
                        onTriggered: {
                            Global.removeContactRequested(root.publicKey, d.contactDetails)
                        }
                    }
                    StatusAction {
                        text: qsTr("Block user")
                        icon.name: "cancel"
                        type: StatusAction.Type.Danger
                        enabled: !d.isBlocked
                        onTriggered: {
                            Global.blockContactRequested(root.publicKey, d.contactDetails)
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
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
                    isBlocked: d.isBlocked
                    tiny: false
                }
            }
            RowLayout {
                spacing: Style.current.halfPadding
                StatusBaseText {
                    id: contactSecondaryName
                    color: Theme.palette.baseColor1
                    text: d.optionalDisplayName
                    visible: !!d.userNickName
                }
                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.preferredHeight: 4
                    radius: width/2
                    color: Theme.palette.baseColor1
                    visible: contactSecondaryName.visible
                }
                StatusBaseText {
                    color: Theme.palette.baseColor1
                    text: Utils.getElidedCompressedPk(root.publicKey)
                    HoverHandler {
                        id: keyHoverHandler
                    }
                    StatusToolTip {
                        text: Utils.getCompressedPk(root.publicKey)
                        visible: keyHoverHandler.hovered
                    }
                }
                CopyButton {
                    Layout.leftMargin: -4
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    textToCopy: Utils.getCompressedPk(root.publicKey)
                    StatusToolTip {
                        text: qsTr("Copy Chat Key")
                        visible: parent.hovered
                    }
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.halfPadding
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.dirty ? root.dirtyValues.bio : d.contactDetails.bio
                visible: !!text
            }
            EmojiHash {
                Layout.topMargin: Style.current.halfPadding
                objectName: "ProfileDialog_userEmojiHash"
                publicKey: root.publicKey
                oneRow: true
            }
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
                    // StatusTabButton {
                    //     width: implicitWidth
                    //     text: qsTr("Assets")
                    // }
                }

                // Profile Showcase
                ProfileShowcaseView {
                    Layout.fillWidth: true
                    Layout.topMargin: -column.spacing
                    Layout.preferredHeight: 300

                    currentTabIndex: showcaseTabBar.currentIndex
                    publicKey: root.publicKey
                    mainDisplayName: d.mainDisplayName
                    readOnly: root.readOnly
                    profileStore: root.profileStore
                    walletStore: root.walletStore
                    networkConnectionStore: root.networkConnectionStore
                    
                    livePreview: root.dirty
                    livePreviewValues: root.dirtyValues

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
