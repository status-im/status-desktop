import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.controls 1.0
import shared.controls.chat 1.0

StatusDialog {
    id: root

    required property string publicKey
    required property var contactDetails

    default property alias content: contentLayout.children

    property ObjectModel rightButtons

    readonly property string mainDisplayName: ProfileUtils.displayName(contactDetails.localNickname, contactDetails.name,
                                                                       contactDetails.displayName, contactDetails.alias)
    readonly property string optionalDisplayName: ProfileUtils.displayName("", contactDetails.name, contactDetails.displayName, contactDetails.alias)

    width: 480
    horizontalPadding: 16
    verticalPadding: 20

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.padding

            UserImage {
                name: root.mainDisplayName
                pubkey: root.publicKey
                image: Utils.addTimestampToURL(contactDetails.largeImage)
                interactive: false
                imageWidth: 60
                imageHeight: 60
                ensVerified: contactDetails.ensVerified
                onlineStatus: contactDetails.onlineStatus
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
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.verticalCenter: contactName.verticalCenter
                        isContact: contactDetails.isContact
                        trustIndicator: contactDetails.trustStatus
                        isBlocked: contactDetails.isBlocked
                        tiny: false
                    }
                }
                RowLayout {
                    spacing: Style.current.halfPadding
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
                            text: Utils.getCompressedPk(root.publicKey)
                            visible: keyHoverHandler.hovered
                        }
                    }
                }
                EmojiHash {
                    Layout.topMargin: 4
                    publicKey: root.publicKey
                    oneRow: true
                }
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
            Layout.topMargin: 15
            Layout.bottomMargin: 15
        }

        ColumnLayout {
            id: contentLayout
        }
    }

    footer: StatusDialogFooter {
        rightButtons: root.rightButtons
    }
}
