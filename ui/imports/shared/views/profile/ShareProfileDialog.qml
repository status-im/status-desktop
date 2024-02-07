import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.controls 1.0

StatusDialog {
    id: root

    required property string publicKey
    required property string qrCode
    required property string linkToProfile

    footer: null

    width: 500

    topPadding: Style.current.padding
    bottomPadding: Style.current.xlPadding
    horizontalPadding: 80

    contentItem: ColumnLayout {
        spacing: Style.current.halfPadding

        Image {
            Layout.preferredWidth: 290
            Layout.preferredHeight: 290
            Layout.alignment: Qt.AlignHCenter
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            mipmap: true
            smooth: false
            source: root.qrCode
        }

        StatusBaseText {
            Layout.topMargin: Style.current.smallPadding
            Layout.fillWidth: true
            text: qsTr("Profile link")
        }

        StatusBaseInput {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            leftPadding: Style.current.padding
            rightPadding: Style.current.halfPadding
            topPadding: 0
            bottomPadding: 0
            placeholder.rightPadding: Style.current.halfPadding
            placeholderText: root.linkToProfile
            placeholderTextColor: Theme.palette.directColor1
            edit.readOnly: true
            background.color: "transparent"
            background.border.color: Theme.palette.baseColor2
            rightComponent: CopyButton {
                textToCopy: root.linkToProfile
                StatusToolTip {
                    text: qsTr("Copy link")
                    visible: parent.hovered
                }
            }
        }

        StatusBaseText {
            Layout.topMargin: Style.current.halfPadding
            Layout.fillWidth: true
            text: qsTr("Emoji hash")
        }

        StatusBaseInput {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            leftPadding: Style.current.padding
            rightPadding: Style.current.halfPadding
            topPadding: 0
            bottomPadding: 0
            edit.readOnly: true
            background.color: "transparent"
            background.border.color: Theme.palette.baseColor2
            leftComponent: EmojiHash {
                publicKey: root.publicKey
                oneRow: true
            }
            rightComponent: CopyButton {
                textToCopy: Utils.getEmojiHashAsJson(root.publicKey).join("").toString()
                StatusToolTip {
                    text: qsTr("Copy emoji hash")
                    visible: parent.hovered
                }
            }
        }
    }
}
