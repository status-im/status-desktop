import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0
import shared.controls.chat 1.0

StatusDialog {
    id: root

    property string publicKey: ""
    property bool loadingContactDetails: false
    property string localNickname
    property string name
    property string displayName
    property string alias
    property bool ensVerified
    property int onlineStatus
    property string largeImage
    property bool isContact
    property int trustStatus
    property bool isBlocked

    default property alias content: contentLayout.children

    property ObjectModel rightButtons

    readonly property string mainDisplayName: StatusQUtils.Emoji.parse(
                                                  ProfileUtils.displayName(localNickname, name,
                                                                           displayName, alias))
    readonly property string optionalDisplayName: StatusQUtils.Emoji.parse(
                                                      ProfileUtils.displayName("", name, displayName, alias))

    width: Math.max(implicitWidth, 480)
    horizontalPadding: 0
    topPadding: 20
    bottomPadding: 0

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            spacing: Style.current.padding

            UserImage {
                name: root.mainDisplayName
                pubkey: root.publicKey
                image: Utils.addTimestampToURL(root.largeImage)
                interactive: false
                imageWidth: 60
                imageHeight: 60
                ensVerified: root.ensVerified
                onlineStatus: root.onlineStatus
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
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.verticalCenter: contactName.verticalCenter
                        isContact: root.isContact
                        trustIndicator: root.trustStatus
                        isBlocked: root.isBlocked
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
                        visible: !!root.localNickname
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
            Layout.topMargin: Style.current.padding
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
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
