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

    /*!
       \qmlproperty string TokenHolderListItem::pubKey
       This property holds the chat public key of the member represented.
    */
    property string pubKey
    /*!
       \qmlproperty string TokenHolderListItem::walletAddress
       This property holds the wallet address of the member represented.
    */
    property string walletAddress
    /*!
       \qmlproperty int TokenHolderListItem::numberOfMessages
        This property holds the number of messages sent by the member represented.
    */
    property int numberOfMessages: 0
    /*!
       \qmlproperty string TokenHolderListItem::amount
       This property holds the amount of tokens held by the member represented.
    */
    property string amount: "0"

    /*!
       \qmlproperty string TokenHolderListItem::nickName
       This property holds the nick name of the member represented.
    */
    property string nickName: ""
    /*!
       \qmlproperty string TokenHolderListItem::userName
       This property holds the user name of the member represented.
    */
    property string userName: ""
    /*!
       \qmlproperty string TokenHolderListItem::compressedPubKey
       This property holds the compressed public key of the member represented.
    */
    property string compressedPubKey: ""
    /*!
       \qmlproperty bool TokenHolderListItem::isContact
       This property holds if the member represented is contact.
    */
    property bool isContact: false
    /*!
       \qmlproperty bool TokenHolderListItem::isVerified
       This property holds if the member represented is verified contact.
    */
    property bool isVerified: false
    /*!
       \qmlproperty bool TokenHolderListItem::isEnsVerified
       This property holds if the member's ENS name was verified.
    */
    property bool isEnsVerified: false
    /*!
       \qmlproperty int TokenHolderListItem::trustStatus
     This property holds the trust status of the member represented.
    */
    property int trustStatus: 0
    /*!
       \qmlproperty int TokenHolderListItem::memberRole
        This property holds the member role (admin, owner, etc.) of the member represented.
    */
    property int memberRole: 0
    /*!
       \qmlproperty string TokenHolderListItem::iconName
        This property holds the icon name of the member represented.
    */
    property string iconName
    /*!
       \qmlproperty bool TokenHolderListItem::isUntrustworthy
       This property holds if the member represented is untrustworthy.
    */
    property bool isUntrustworthy: false

    /*!
       \qmlproperty int TokenHolderListItem::status
       This property holds the connectivity status of the member represented.

    int unknown: -1
    int inactive: 0
    int online: 1

    */
    // FIXME: move Constants.onlineStatus from status-desktop
    property int onlineStatus: 0

    readonly property string addressElided:
        StatusQUtils.Utils.elideAndFormatWalletAddress(root.walletAddress)

    signal clicked(var mouse)

    onRemotelyDestructInProgressChanged: {
        if (!remotelyDestructInProgress)
            colorAnimation.restart()
    }

    padding: 0
    horizontalPadding: Theme.padding
    topPadding: showSeparator ? Theme.halfPadding : 0

    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.topPadding

            radius: Theme.radius
            color: root.hovered || root.isCurrentItem ? Theme.palette.baseColor2 : "transparent"
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.topPadding

            radius: Theme.radius
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
            hoverEnabled: false
            nickName: root.nickName
            userName: root.userName
            pubKey: root.isEnsVerified ? "" : root.compressedPubKey
            isContact: root.isContact
            isVerified: root.trustStatus === Constants.trustStatus.trusted
            isUntrustworthy: root.trustStatus === Constants.trustStatus.untrustworthy
            isOwner: root.memberRole === Constants.memberRole.owner
            status: root.onlineStatus
            icon.name: root.iconName
            icon.color: Utils.colorForPubkey(root.pubKey)
            ringSettings.ringSpecModel: Utils.getColorHashAsJson(root.pubKey)
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
            asset.color: Theme.palette.userCustomizationColors[d.red2Color]
        }
    }

    contentItem: Item {
        implicitWidth: delegateRow.implicitWidth
        implicitHeight: delegateRow.implicitHeight

        RowLayout {
            id: delegateRow

            spacing: Theme.padding

            Loader {
                Layout.preferredWidth: root.usernameHeaderWidth
                sourceComponent: !!root.pubKey  ? communityMemberContentItem : bareAddressContentItem
            }

            TokenHolderNumberCell {
                Layout.preferredWidth: root.noOfMessagesHeaderWidth

                text: root.pubKey
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
                    font.pixelSize: Theme.tertiaryTextFontSize
                    visible: root.remotelyDestructInProgress
                    color: Theme.palette.directColor1
                }

                TokenHolderNumberCell {
                    Layout.alignment: Qt.AlignRight
                    text: root.amount
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

    StatusMouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.AllButtons
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked(mouse)
    }
}
