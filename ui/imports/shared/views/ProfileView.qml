import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: root

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: profileStore.pubkey
    property string userDisplayName: profileStore.displayName
    property string userName: profileStore.username
    property string userNickname: profileStore.details.localNickname
    property string userEnsName: profileStore.ensName
    property string userIcon: profileStore.profileLargeImage
    property string text: ""

    property bool userIsEnsVerified: profileStore.details.ensVerified
    property bool userIsBlocked: profileStore.details.isBlocked
    property bool isCurrentUser: profileStore.pubkey === userPublicKey
    property bool isAddedContact: false

    property int userTrustStatus: Constants.trustStatus.unknown
    property int verificationStatus: Constants.verificationStatus.unverified

    property string challenge: ""
    property string response: ""

    property bool userIsUntrustworthy: false
    property bool userTrustIsUnknown: false
    property bool isContact: false
    property bool isVerificationSent: false
    property bool isVerified: false
    property bool isTrusted: false
    property bool hasReceivedVerificationRequest: false

    property bool showRemoveVerified: false
    property bool showVerifyIdentitySection: false
    property bool showVerificationPendingSection: false
    property bool showIdentityVerified: false
    property bool showIdentityVerifiedUntrustworthy: false

    property string verificationChallenge: ""
    property string verificationResponse: ""
    property string verificationResponseDisplayName: ""
    property string verificationResponseIcon: ""
    property string verificationRequestedAt: ""
    property string verificationRepliedAt: ""

    readonly property alias qrCodePopup: qrCodePopup
    readonly property alias unblockContactConfirmationDialog: unblockContactConfirmationDialog
    readonly property alias blockContactConfirmationDialog: blockContactConfirmationDialog
    readonly property alias removeContactConfirmationDialog: removeContactConfirmationDialog
    readonly property alias wizardAnimation: wizardAnimation
    readonly property alias challengeTxt: challengeTxt
    readonly property alias stepsListModel: stepsListModel

    readonly property int animationDuration: 500

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)
    signal contactAdded(publicKey: string)
    signal contactRemoved(publicKey: string)
    signal nicknameEdited(publicKey: string)

    implicitWidth: modalContent.implicitWidth
    implicitHeight: modalContent.implicitHeight

    color: Theme.palette.statusAppLayout.backgroundColor
    radius: 8

    QtObject {
        id: d
        readonly property string subTitle: root.userIsEnsVerified ? root.userName : Utils.getElidedCompressedPk(userPublicKey)
        readonly property int subTitleElide: Text.ElideMiddle
    }

    SequentialAnimation {
        id: wizardAnimation
        ScriptAction {
            id: step1
            property int loadingTime: 0
            Behavior on loadingTime { NumberAnimation { duration: animationDuration }}
            onLoadingTimeChanged: {
                if (isVerificationSent) {
                    stepsListModel.setProperty(1, "loadingTime", step1.loadingTime);
                }
            }
            script: {
                step1.loadingTime = animationDuration;
                stepsListModel.setProperty(0, "loadingTime", step1.loadingTime);

                if (isVerificationSent) {
                    stepsListModel.setProperty(0, "stepCompleted", true);
                }
            }
        }
        PauseAnimation {
            duration: animationDuration + 100
        }
        ScriptAction {
            id: step2
            property int loadingTime: 0
            Behavior on loadingTime { NumberAnimation { duration: animationDuration } }
            onLoadingTimeChanged: {
                if (isVerificationSent && !!verificationResponse) {
                    stepsListModel.setProperty(2, "loadingTime", step2.loadingTime);
                }
            }
            script: {
                if (isVerificationSent && !!verificationChallenge) {
                    step2.loadingTime = animationDuration;
                    if (isVerificationSent && !!verificationResponse) {
                        stepsListModel.setProperty(1, "stepCompleted", true);
                    }
                }
            }
        }
        PauseAnimation {
            duration: animationDuration + 100
        }
        ScriptAction {
            script: {
                if (verificationStatus === Constants.verificationStatus.trusted) {
                    stepsListModel.setProperty(2, "stepCompleted", true);
                }
            }
        }
    }

    ColumnLayout {
        id: modalContent
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            implicitHeight: 32
        }

        ProfileHeader {
            Layout.fillWidth: true

            displayName: root.userDisplayName
            pubkey: root.userPublicKey
            icon: root.isCurrentUser ? root.profileStore.profileLargeImage : root.userIcon
            trustStatus: root.userTrustStatus
            isContact: root.isContact
            store: root.profileStore
            isCurrentUser: root.isCurrentUser

            displayNameVisible: false
            displayNamePlusIconsVisible: true
            pubkeyVisibleWithCopy: true
            pubkeyVisible: false
            imageSize: ProfileHeader.ImageSize.Middle
            editImageButtonVisible: root.isCurrentUser
            onEditClicked: {
                if(!isCurrentUser){
                    nicknamePopup.open()
                } else {
                    Global.openEditDisplayNamePopup()
                }
            }
        }

        StatusBanner {
            Layout.fillWidth: true
            visible: root.userIsBlocked
            type: StatusBanner.Type.Danger
            statusText: qsTr("Blocked")
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            visible: !showVerifyIdentitySection && !showVerificationPendingSection && !showIdentityVerified
            title: qsTr("Chat key")
            subTitle: Utils.getCompressedPk(root.userPublicKey)
            subTitleComponent.elide: Text.ElideMiddle
            subTitleComponent.width: 320
            subTitleComponent.font.family: Theme.palette.monoFont.name
            tooltip.text: qsTr("Copied to clipboard")
            tooltip.timeout: 1000
            icon.name: "copy"
            iconButton.onClicked: {
                globalUtils.copyToClipboard(subTitle)
                tooltip.open();
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            visible: !showVerifyIdentitySection && !showVerificationPendingSection && !showIdentityVerified
            title: qsTr("Share Profile URL")
            subTitle: {
                let user = ""
                if (isCurrentUser) {
                    user = root.profileStore.ensName !== "" ? root.profileStore.ensName  : Utils.elideText(root.profileStore.pubkey, 5)
                } else if (userIsEnsVerified) {
                    user = userEnsName
                }

                if (user === ""){
                    user = Utils.elideText(userPublicKey, 5)
                }
                return Constants.userLinkPrefix +  user;
            }
            tooltip.text: qsTr("Copied to clipboard")
            tooltip.timeout: 1000
            icon.name: "copy"
            iconButton.onClicked: {
                let user = ""
                if (isCurrentUser) {
                    user = root.profileStore.ensName !== "" ? root.profileStore.ensName : root.profileStore.pubkey
                } else {
                    user = (userEnsName !== "" ? userEnsName : userPublicKey)
                }
                root.profileStore.copyToClipboard(Constants.userLinkPrefix + user)
                tooltip.open();
            }
        }

        ListModel {
            id: stepsListModel
            ListElement {description: qsTr("Send Request"); loadingTime: 0; stepCompleted: false}
            ListElement {description: qsTr("Receive Response"); loadingTime: 0; stepCompleted: false}
            ListElement {description: qsTr("Confirm Identity"); loadingTime: 0; stepCompleted: false}
        }

        StatusWizardStepper {
            id: wizardStepper
            maxDuration: animationDuration
            visible: showVerifyIdentitySection || showVerificationPendingSection || showIdentityVerified || showIdentityVerifiedUntrustworthy
            width: parent.width
            stepsModel: stepsListModel
        }

        Separator {
            visible: wizardStepper.visible
            implicitHeight: 32
        }

        StatusBaseText {
            id: confirmLbl
            visible: showIdentityVerified
            text: qsTr("You have confirmed %1's identity. From now on this verification emblem will always be displayed alongside %1's nickname.").arg(userIsEnsVerified ? userEnsName : userDisplayName)
            font.pixelSize: Style.current.additionalTextSize
            horizontalAlignment : Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 363
            wrapMode: Text.WordWrap
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            id: confirmUntrustworthyLbl
            visible: showIdentityVerifiedUntrustworthy
            text: qsTr("You have marked %1 as Untrustworthy. From now on this Untrustworthy emblem will always be displayed alongside %1's nickname.").arg(userIsEnsVerified ? userEnsName : userDisplayName)
            font.pixelSize: Style.current.additionalTextSize
            horizontalAlignment : Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 363
            wrapMode: Text.WordWrap
            color: Theme.palette.baseColor1
        }

        Item {
            visible: checkboxIcon.visible || dangerIcon.visible
            Layout.fillWidth: true
            implicitHeight: visible ? 16 : 0
        }

        StatusRoundIcon {
            id: checkboxIcon
            visible: confirmLbl.visible
            icon.name: "checkbox"
            icon.width: 16
            icon.height: 16
            icon.color: Theme.palette.white
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.primaryColor1
            width: 32
            height: 32
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            visible: !showVerifyIdentitySection && !showVerificationPendingSection && !showIdentityVerified
            title: root.userIsEnsVerified ? qsTr("ENS username") : qsTr("Username")
            subTitle: root.userIsEnsVerified ? root.userEnsName : root.userName
            tooltip.text: qsTr("Copied to clipboard")
            tooltip.timeout: 1000
            icon.name: "copy"
            iconButton.onClicked: {
                globalUtils.copyToClipboard(subTitle)
                tooltip.open();
            }
        }

        StatusRoundIcon {
            id: dangerIcon
            visible: confirmUntrustworthyLbl.visible
            icon.name: "tiny/subtract"
            icon.width: 5
            icon.height: 21
            icon.color: Theme.palette.white
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.dangerColor1
            width: 32
            height: 32
        }

        Item {
            visible: checkboxIcon.visible || dangerIcon.visible
            height: visible ? 16 : 0
            Layout.fillWidth: true
        }

        StatusInput {
            id: challengeTxt
            visible: showVerifyIdentitySection
            charLimit: 280
            input.text: root.challenge
            Layout.fillWidth: true
            Layout.rightMargin: d.contentMargins
            Layout.leftMargin: d.contentMargins
            input.multiline: true
            input.implicitHeight: 152
            input.placeholderText: qsTr("Ask a question that only the real %1 will be able to answer e.g. a question about a shared experience, or ask Mark to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).").arg(userIsEnsVerified ? userEnsName : userDisplayName)
        }

        MessageView {
            id: challengeMessage
            visible: root.showVerificationPendingSection
            Layout.fillWidth: true
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: root.verificationRequestedAt
            senderDisplayName: userProfile.name
            senderIcon: userProfile.icon
            message: root.verificationChallenge
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        MessageView {
            id: responseMessage
            visible: root.showVerificationPendingSection && !!root.verificationResponse
            width: parent.width
            isMessage: true
            shouldRepeatHeader: true
            messageTimestamp: root.verificationRepliedAt
            senderDisplayName: root.verificationResponseDisplayName
            senderIcon: root.verificationResponseIcon
            message: root.verificationResponse
            messageContentType: Constants.messageContentType.messageType
            placeholderMessage: true
        }

        Item {
            visible: waitingForText.visible
            height: 32
            Layout.fillWidth: true
        }

        StatusBaseText {
            id: waitingForText
            visible: showVerificationPendingSection  && !verificationResponse
            text: qsTr("Waiting for %1's response...").arg(userIsEnsVerified ? userEnsName : userDisplayName)
            font.pixelSize: Style.current.additionalTextSize
            horizontalAlignment : Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 363
            wrapMode: Text.WordWrap
            color: Theme.palette.baseColor1
        }

        Item {
            height: 32
            Layout.fillWidth: true
        }
    }

    // TODO: replace with StatusModal
    ModalPopup {
        id: qrCodePopup
        width: 320
        height: 320
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: globalUtils.qrCode(userPublicKey)
            anchors.horizontalCenter: parent.horizontalCenter
            height: 212
            width: 212
            mipmap: true
            smooth: false
        }
    }

    UnblockContactConfirmationDialog {
        id: unblockContactConfirmationDialog
        onUnblockButtonClicked: {
            root.contactsStore.unblockContact(userPublicKey)
            unblockContactConfirmationDialog.close();
            root.contactUnblocked(userPublicKey)
        }
    }

    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            root.contactsStore.blockContact(userPublicKey)
            blockContactConfirmationDialog.close();
            root.contactBlocked(userPublicKey)
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        header.title: qsTr("Remove contact")
        confirmationText: qsTr("Are you sure you want to remove this contact?")
        onConfirmButtonClicked: {
            if (isAddedContact) {
                root.contactsStore.removeContact(userPublicKey);
            }
            removeContactConfirmationDialog.close();
            root.contactRemoved(userPublicKey)
        }
    }

    NicknamePopup {
        id: nicknamePopup
        nickname: root.userNickname
        header.subTitle: d.subTitle
        header.subTitleElide: d.subTitleElide
        onEditDone: {
            if (root.userNickname !== newNickname)
            {
                root.userNickname = newNickname;
                root.contactsStore.changeContactNickname(userPublicKey, newNickname);
            }
            root.nicknameEdited(userPublicKey)
        }
    }
}
