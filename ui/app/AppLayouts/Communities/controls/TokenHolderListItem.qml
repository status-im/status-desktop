import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

/*!
   \qmltype TokenHolderListItem
   \inherits ItemDelegate
   \brief Represents a token holder which can be a community member or a bare wallet address
  */

ItemDelegate {
    id: root

    property int usernameHeaderWidth: 0
    property int noOfMessagesHeaderWidth: 0
    property int holdingHeaderWidth: 0
    property bool isCurrentItem: false

    property bool remotelyDestructInProgress: false
    property bool showSeparator: false
    property bool isFirstRowAddress: false

    property string name
    property string contactId
    property string walletAddress
    property string imageSource
    property int numberOfMessages: 0
    property int amount: 0

    property var contactDetails: null

    readonly property string addressElided:
        StatusQUtils.Utils.elideAndFormatWalletAddress(root.walletAddress)

    signal clicked(var mouse)

    function updateContactDetails() {
        contactDetails = contactId !== "" ? Utils.getContactDetailsAsJson(contactId, false) : null
    }

    Component.onCompleted: root.updateContactDetails()
    onContactIdChanged: root.updateContactDetails()

    onRemotelyDestructInProgressChanged: {
        if (!remotelyDestructInProgress)
            colorAnimation.restart()
    }

    padding: 0
    horizontalPadding: Style.current.padding
    topPadding: showSeparator ? Style.current.halfPadding : 0

    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.topPadding

            radius: Style.current.radius
            color: root.hovered || root.isCurrentItem ? Theme.palette.baseColor2 : "transparent"
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.topPadding

            radius: Style.current.radius
            color: "transparent"

            SequentialAnimation on color {
                id: colorAnimation

                running: false

                PropertyAction { value: Theme.palette.primaryColor3 }
                PauseAnimation { duration: 1000 }
                ColorAnimation { to: "transparent"; duration: 500 }
            }
        }

        Rectangle {
            visible: root.showSeparator

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: 1
            color: Theme.palette.baseColor2
        }
    }

    Component {
        id: communityMemberContentItem

        StatusMemberListItem {
            color: "transparent"
            leftPadding: 0
            rightPadding: 0
            sensor.enabled: false
            nickName: root.contactDetails.localNickname
            userName: ProfileUtils.displayName("", root.contactDetails.ensName, root.contactDetails.displayName, root.contactDetails.alias)
            pubKey: root.contactDetails.isEnsVerified ? "" : Utils.getCompressedPk(root.contactId)
            isContact: root.contactDetails.isContact
            isVerified: root.contactDetails.verificationStatus === Constants.verificationStatus.verified
            isUntrustworthy: root.contactDetails.trustStatus == Constants.trustStatus.untrustworthy
            isAdmin: root.contactDetails.memberRole === Constants.memberRole.owner
            status: root.contactDetails.onlineStatus
            asset.name: root.contactDetails.displayIcon
            asset.isImage: (asset.name !== "")
            asset.isLetterIdenticon: (asset.name === "")
            asset.color: Utils.colorForPubkey(root.contactId)
            ringSettings.ringSpecModel: Utils.getColorHashAsJson(root.contactId)
        }
    }

    Component {
        id: bareAddressContentItem

        StatusListItem {
            color: "transparent"
            leftPadding: 0
            rightPadding: 0
            sensor.enabled: false
            title: root.addressElided
            statusListItemIcon.name: "?"
            statusListItemSubTitle.font.pixelSize: Theme.asideTextFontSize
            statusListItemSubTitle.lineHeightMode: Text.FixedHeight
            statusListItemSubTitle.lineHeight: 14
            asset.name: root.imageSource
            asset.isImage: true
            asset.isLetterIdenticon: true
            asset.color: Theme.palette.userCustomizationColors[d.red2Color]
        }
    }

    contentItem: Item {
        implicitWidth: delegateRow.implicitWidth
        implicitHeight: delegateRow.implicitHeight

        RowLayout {
            id: delegateRow

            spacing: Style.current.padding

            Loader {
                Layout.preferredWidth: root.usernameHeaderWidth
                sourceComponent: contactDetails ? communityMemberContentItem : bareAddressContentItem
            }

            TokenHolderNumberCell {
                Layout.preferredWidth: root.noOfMessagesHeaderWidth

                text: root.name
                        ? LocaleUtils.numberToLocaleString(root.numberOfMessages)
                        : "-"
            }

            RowLayout {
                Layout.preferredWidth: root.holdingHeaderWidth
                spacing: 4

                StatusBaseText {
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignRight

                    text: StatusQUtils.Emoji.fromCodePoint("1f525") // :fire: emoji
                    font.pixelSize: Style.current.tertiaryTextFontSize
                    visible: root.remotelyDestructInProgress
                    color: Theme.palette.directColor1
                }

                TokenHolderNumberCell {
                    Layout.alignment: Qt.AlignRight
                    text: LocaleUtils.numberToLocaleString(root.amount)
                }

                StatusLoadingIndicator {
                    Layout.preferredHeight: Theme.primaryTextFontSize
                    Layout.preferredWidth: Layout.preferredHeight
                    Layout.leftMargin: 6
                    visible: root.remotelyDestructInProgress
                    color: Theme.palette.primaryColor1
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.AllButtons
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked(mouse)
    }
}
