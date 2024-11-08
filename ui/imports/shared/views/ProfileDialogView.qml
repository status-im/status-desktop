import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0 as SharedStores
import shared.views.profile 1.0
import utils 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Profile.helpers 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores
import AppLayouts.Wallet.stores 1.0 as WalletStores

Pane {
    id: root

    property bool readOnly // inside settings/profile/preview

    property string publicKey: contactsStore.myPublicKey
    readonly property alias isCurrentUser: d.isCurrentUser

    property ProfileStores.ProfileStore profileStore
    property ProfileStores.ContactsStore contactsStore
    property SharedStores.UtilsStore utilsStore
    property WalletStores.RootStore walletStore
    
    property alias sendToAccountEnabled: showcaseView.sendToAccountEnabled

    property var dirtyValues: ({})
    property bool dirty: false

    property var showcaseCommunitiesModel
    property var showcaseAccountsModel
    property var showcaseCollectiblesModel
    property var showcaseSocialLinksModel
    property var showcaseAssetsModel
    
    property alias showcaseMaxVisibility: showcaseView.maxVisibility

    property alias assetsModel: showcaseView.globalAssetsModel
    property alias collectiblesModel: showcaseView.globalCollectiblesModel

    signal closeRequested()

    padding: 0
    topPadding: 32

    background: StatusDialogBackground {
        id: background
    }

    ContactDetails {
        id: contactDetails
        publicKey: root.publicKey
        contactsStore: root.contactsStore
        profileStore: root.profileStore
    }

    QtObject {
        id: d

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

        readonly property bool isLocallyTrusted: contactDetails.trustStatus === Constants.trustStatus.trusted

        readonly property string linkToProfile: root.contactsStore.getLinkToProfile(root.publicKey)

        readonly property var emojiHash: root.utilsStore.getEmojiHash(root.publicKey)
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
            objectName: "sendMessageButton"
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
            onClicked: Global.openReviewContactRequestPopup(root.publicKey, null)
        }
    }

    Component {
        id: btnSendContactRequestComponent
        StatusButton {
            objectName: "profileDialog_sendContactRequestButton"
            size: StatusButton.Size.Small
            text: qsTr("Send contact request")
            onClicked: Global.openContactRequestPopup(root.publicKey, null)
        }
    }

    Component {
        id: btnBlockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            type: StatusBaseButton.Type.Danger
            objectName: "blockUserButton"
            text: qsTr("Block user")
            onClicked: Global.blockContactRequested(root.publicKey)
        }
    }

    Component {
        id: btnUnblockUserComponent
        StatusButton {
            size: StatusButton.Size.Small
            objectName: "unblockUserProfileButton"
            text: qsTr("Unblock user")
            onClicked: Global.unblockContactRequested(root.publicKey)
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
        id: btnShareProfile
        StatusFlatButton {
            objectName: "shareProfileButton"
            size: StatusButton.Size.Small
            text: qsTr("Share Profile")
            onClicked: Global.openPopup(shareProfileCmp)
        }
    }

    Component {
        id: shareProfileCmp
        ShareProfileDialog {
            destroyOnClose: true
            title: d.isCurrentUser ? qsTr("Share your profile") : qsTr("%1's profile").arg(StatusQUtils.Emoji.parse(d.mainDisplayName))
            publicKey: root.publicKey
            emojiHash: d.emojiHash
            linkToProfile: d.linkToProfile
            qrCode: root.profileStore.getQrCodeSource(linkToProfile)
            displayName: userImage.name
            largeImage: userImage.image
            colorId: root.profileStore.colorId
        }
    }

    ColumnLayout {
        id: column
        spacing: 20
        anchors {
            fill: parent
            leftMargin: Theme.bigPadding
            rightMargin: Theme.bigPadding
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.halfPadding

            UserImage {
                id: userImage
                Layout.alignment: Qt.AlignTop
                objectName: "ProfileDialog_userImage"
                name: root.dirty ? root.dirtyValues.displayName
                                 : d.mainDisplayName
                image: root.dirty ? root.dirtyValues.profileLargeImage
                                  : Utils.addTimestampToURL(contactDetails.largeImage)
                colorId: contactDetails.colorId
                colorHash: contactDetails.colorHash

                interactive: false
                imageWidth: 90
                imageHeight: imageWidth
                ensVerified: contactDetails.ensVerified

                Binding on onlineStatus {
                    value: contactDetails.onlineStatus
                    when: !d.isCurrentUser
                }
            }

            Item { Layout.fillWidth: true }

            // secondary action button
            Loader {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: menuButton.visible ? menuButton.height : -1
                active: d.isCurrentUser && !root.readOnly
                sourceComponent: btnShareProfile
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
                                 contactDetails.trustStatus === Constants.trustStatus.untrustworthy // we have an action button otherwise
                        onTriggered: Global.openContactRequestPopup(root.publicKey, null)
                    }
                    StatusAction {
                        text: qsTr("Mark as trusted")
                        icon.name: "checkmark-circle"
                        enabled: d.isContact && !d.isBlocked && !d.isLocallyTrusted
                        onTriggered: Global.openMarkAsIDVerifiedPopup(root.publicKey, null)
                    }
                    StatusAction {
                        objectName: "addEditNickNameStatusAction"
                        text: d.userNickName ? qsTr("Edit nickname") : qsTr("Add nickname")
                        icon.name: "edit_pencil"
                        onTriggered: Global.openNicknamePopupRequested(root.publicKey, null)
                    }
                    StatusAction {
                        text: qsTr("Show QR code")
                        icon.name: "qr"
                        enabled: !d.isCurrentUser
                        onTriggered: Global.openPopup(shareProfileCmp)
                    }
                    StatusAction {
                        text: qsTr("Copy link to profile")
                        icon.name: "copy"
                        onTriggered: ClipboardUtils.setText(d.linkToProfile)
                    }
                    StatusMenuSeparator {}
                    StatusAction {
                        text: qsTr("Remove trusted mark")
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && d.isLocallyTrusted
                        onTriggered: Global.openRemoveIDVerificationDialog(root.publicKey, null)
                    }
                    StatusAction {
                        text: qsTr("Remove nickname")
                        objectName: "removeNicknameStatusAction"
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                        enabled: !d.isCurrentUser && !!contactDetails.localNickname
                        onTriggered: root.contactsStore.changeContactNickname(root.publicKey, "", d.optionalDisplayName, true)
                    }
                    StatusAction {
                        text: qsTr("Mark as untrusted")
                        icon.name: "warning"
                        type: StatusAction.Type.Danger
                        enabled: contactDetails.trustStatus !== Constants.trustStatus.untrustworthy && !d.isBlocked
                        onTriggered: Global.markAsUntrustedRequested(root.publicKey)
                    }
                    StatusAction {
                        text: qsTr("Remove untrusted mark")
                        icon.name: "warning"
                        type: StatusAction.Type.Danger
                        enabled: contactDetails.trustStatus === Constants.trustStatus.untrustworthy && !d.isBlocked
                        onTriggered: root.contactsStore.removeTrustStatus(root.publicKey)
                    }
                    StatusAction {
                        text: qsTr("Remove contact")
                        icon.name: "remove-contact"
                        type: StatusAction.Type.Danger
                        enabled: d.isContact && !d.isBlocked && d.contactRequestState !== Constants.ContactRequestState.Sent
                        onTriggered: Global.removeContactRequested(root.publicKey)
                    }
                    StatusAction {
                        text: qsTr("Block user")
                        objectName: "blockUserStatusAction"
                        icon.name: "cancel"
                        type: StatusAction.Type.Danger
                        enabled: !d.isBlocked
                        onTriggered: Global.blockContactRequested(root.publicKey)
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
                    text: StatusQUtils.Emoji.parse(root.dirty ? root.dirtyValues.displayName : d.mainDisplayName, StatusQUtils.Emoji.size.middle)
                }
                StatusContactVerificationIcons {
                    id: verificationIcons
                    anchors.left: contactName.right
                    anchors.leftMargin: Theme.halfPadding
                    anchors.verticalCenter: contactName.verticalCenter
                    objectName: "ProfileDialog_userVerificationIcons"
                    visible: !d.isCurrentUser
                    isContact: d.isContact
                    trustIndicator: contactDetails.trustStatus
                    isBlocked: d.isBlocked
                    tiny: false
                }
            }
            RowLayout {
                spacing: Theme.halfPadding
                StatusBaseText {
                    id: contactSecondaryName
                    color: Theme.palette.baseColor1
                    text: StatusQUtils.Emoji.parse(d.optionalDisplayName)
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
                        text: root.utilsStore.getCompressedPk(root.publicKey)
                        visible: keyHoverHandler.hovered
                    }
                }
                CopyButton {
                    Layout.leftMargin: -4
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    textToCopy: root.utilsStore.getCompressedPk(root.publicKey)
                    StatusToolTip {
                        text: qsTr("Copy Chat Key")
                        visible: parent.hovered
                    }
                }
            }
            StatusScrollView {
                id: bioScrollView
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                Layout.maximumHeight: 120
                contentWidth: availableWidth
                Layout.topMargin: Theme.halfPadding
                padding: 0
                rightPadding: Theme.padding
                visible: !!bioText.text
                StatusBaseText {
                    id: bioText
                    width: bioScrollView.availableWidth
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: root.dirty ? root.dirtyValues.bio.trim() : contactDetails.bio.trim()
                }
            }
            EmojiHash {
                Layout.topMargin: Theme.halfPadding
                objectName: "ProfileDialog_userEmojiHash"
                emojiHash: d.emojiHash
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
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Web")
                    }
                }

                // Profile Showcase
                ProfileShowcaseView {
                    id: showcaseView
                    
                    Layout.fillWidth: true
                    Layout.topMargin: -column.spacing
                    Layout.preferredHeight: 300

                    currentTabIndex: showcaseTabBar.currentIndex
                    mainDisplayName: root.dirty ? root.dirtyValues.displayName
                                     : d.mainDisplayName
                    readOnly: root.readOnly
                    
                    communitiesModel: root.showcaseCommunitiesModel
                    accountsModel: root.showcaseAccountsModel
                    collectiblesModel: root.showcaseCollectiblesModel
                    socialLinksModel: root.showcaseSocialLinksModel
                    // assetsModel: root.showcaseAssetsModel

                    walletStore: root.walletStore

                    onCloseRequested: root.closeRequested()
                    onCopyToClipboard: ClipboardUtils.setText(text)
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
