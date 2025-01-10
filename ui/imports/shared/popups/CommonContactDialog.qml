import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.controls 1.0
import shared.controls.chat 1.0
import shared.stores 1.0
import utils 1.0

StatusDialog {
    id: root

    required property UtilsStore utilsStore

    required property string publicKey
    required property var contactDetails
    property bool loadingContactDetails

    default property alias content: contentLayout.children

    property ObjectModel rightButtons

    readonly property string mainDisplayName: StatusQUtils.Emoji.parse(
                                                  ProfileUtils.displayName(contactDetails.localNickname, contactDetails.name,
                                                                           contactDetails.displayName, contactDetails.alias))
    readonly property string optionalDisplayName: StatusQUtils.Emoji.parse(
                                                      ProfileUtils.displayName("", contactDetails.name, contactDetails.displayName, contactDetails.alias))

    width: Math.max(implicitWidth, 480)
    horizontalPadding: 0
    topPadding: 20
    bottomPadding: 0

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            spacing: Theme.padding

            UserImage {
                name: root.mainDisplayName
                colorHash: contactDetails.colorHash
                colorId: contactDetails.colorId
                image: contactDetails.largeImage
                interactive: false
                imageWidth: 60
                imageHeight: 60
                ensVerified: contactDetails.ensVerified
                onlineStatus: contactDetails.onlineStatus
                loading: root.loadingContactDetails
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Item {
                    id: contactRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    StatusBaseText {
                        id: contactName
                        anchors.left: parent.left
                        width: Math.min(implicitWidth, contactRow.width - verificationIcons.width - verificationIcons.anchors.leftMargin)
                        font.bold: true
                        font.pixelSize: 17
                        elide: Text.ElideRight
                        text: root.mainDisplayName
                    }
                    StatusContactVerificationIcons {
                        id: verificationIcons
                        anchors.left: contactName.right
                        anchors.leftMargin: Theme.halfPadding
                        anchors.verticalCenter: contactName.verticalCenter
                        isContact: contactDetails.isContact
                        trustIndicator: contactDetails.trustStatus
                        isBlocked: contactDetails.isBlocked
                        tiny: false
                    }
                }
                RowLayout {
                    spacing: Theme.halfPadding
                    StatusBaseText {
                        id: contactSecondaryName
                        color: Theme.palette.baseColor1
                        font.pixelSize: 13
                        text: root.optionalDisplayName
                        visible: !!contactDetails.localNickname
                    }
                    Rectangle {
                        Layout.preferredWidth: 4
                        Layout.preferredHeight: 4
                        radius: width/2
                        color: Theme.palette.baseColor1
                        visible: contactSecondaryName.visible
                    }
                    StatusBaseText {
                        font.pixelSize: 13
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
                }
                EmojiHash {
                    Layout.topMargin: 4
                    emojiHash: root.utilsStore.getEmojiHash(root.publicKey)
                    oneRow: true
                }
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
            Layout.topMargin: Theme.padding
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
        }

        StatusScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            id: scrollView

            ColumnLayout {
                width: scrollView.availableWidth
                id: contentLayout
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: root.rightButtons
    }
}
