import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import "./private/statusMessage"

Item {
    id: root

    property StatusMessageSenderDetails sender: StatusMessageSenderDetails { }

    property alias displayNameLabel: primaryDisplayName
    property alias secondaryNameLabel: secondaryDisplayName
    property alias tertiaryDetailsLabel: tertiaryDetailText
    property alias timestamp: timestampText

    property string tertiaryDetail: sender.id
    property string resendText: qsTr("Resend")
    property bool showResendButton: false
    property bool showSendingLoader: false
    property string resendError: ""
    property bool isContact: sender.isContact
    property int trustIndicator: sender.trustIndicator
    property bool amISender: false
    property bool displayNameClickable: true
    property string messageOriginInfo: ""

    signal clicked(var sender, var mouse)
    signal resendClicked()

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    RowLayout {
        id: layout
        spacing: 4
        StatusBaseText {
            id: primaryDisplayName
            objectName: "StatusMessageHeader_DisplayName"
            verticalAlignment: Text.AlignVCenter
            Layout.bottomMargin: 2 // offset for the underline to stay vertically centered
            font.weight: Font.Medium
            font.underline: mouseArea.containsMouse
            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.WordWrap
            color: Theme.palette.primaryColor1
            text: root.amISender ? qsTr("You") : root.sender.displayName
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                enabled: root.displayNameClickable
                hoverEnabled: true
                onClicked: {
                    root.clicked(this, mouse)
                }
            }
        }       
        StatusBaseText {
            id: messageOriginInfo
            verticalAlignment: Text.AlignVCenter
            visible: text
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.asideTextFontSize
            text: root.messageOriginInfo
        }
        StatusContactVerificationIcons {
            id: verificationIcons
            visible: !root.amISender
            isContact: root.isContact
            trustIndicator: root.trustIndicator
        }
        StatusBaseText {
            id: secondaryDisplayName
            verticalAlignment: Text.AlignVCenter
            visible: !root.amISender && !!root.sender.secondaryName
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.asideTextFontSize
            text: `(${root.sender.secondaryName})`
        }
        StatusBaseText {
            verticalAlignment: Text.AlignVCenter
            visible: secondaryDisplayName.visible && tertiaryDetailText.visible
            font.pixelSize: Theme.asideTextFontSize
            color: Theme.palette.baseColor1
            text: "•"
        }
        StatusBaseText {
            id: tertiaryDetailText
            verticalAlignment: Text.AlignVCenter
            visible: !root.amISender && root.messageOriginInfo === "" && text
            font.pixelSize: Theme.asideTextFontSize
            elide: Text.ElideMiddle
            color: Theme.palette.baseColor1
            text: root.tertiaryDetail ? Utils.elideText(root.tertiaryDetail, 5, 3) : ""
        }
        StatusBaseText {
            verticalAlignment: Text.AlignVCenter
            visible: verificationIcons.width <= 0 || secondaryDisplayName.visible || root.amISender || tertiaryDetailText.visible
            font.pixelSize: Theme.asideTextFontSize
            color: Theme.palette.baseColor1
            text: "•"
        }
        StatusTimeStampLabel {
            verticalAlignment: Text.AlignVCenter
            id: timestampText
        }
        StatusBaseText {
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.dangerColor1
            font.pixelSize: Theme.tertiaryTextFontSize
            text: root.resendText
            visible: showResendButton && !!timestampText.text
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: root.resendClicked()
            }
        }
        StatusBaseText {
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.tertiaryTextFontSize
            text: qsTr("Failed to resend: %1").arg(resendError) // TODO replace this with the required design
            visible: resendError && !!timestampText.text
        }
        StatusBaseText {
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.tertiaryTextFontSize
            text: qsTr("Sending...") // TODO replace this with the required design
            visible: showSendingLoader && !!timestampText.text
        }
    }
}
