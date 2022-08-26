import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property StatusMessageSenderDetails sender: StatusMessageSenderDetails { }

    property alias displayNameLabel: primaryDisplayName
    property alias secondaryNameLabel: secondaryDisplayName
    property alias tertiaryDetailsLabel: tertiaryDetailText
    property alias timestamp: timestampText

    property string tertiaryDetail: sender.id
    property string resendText: ""
    property bool showResendButton: false
    property bool isContact: sender.isContact
    property int trustIndicator: sender.trustIndicator
    property bool amISender: false
    property string messageOriginInfo: ""

    signal clicked(var sender, var mouse)
    signal resendClicked()

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    RowLayout {
        id: layout
        spacing: 4
        TextEdit {
            id: primaryDisplayName
            Layout.alignment: Qt.AlignBottom
            font.family: Theme.palette.baseFont.name
            font.weight: Font.Medium
            font.pixelSize: 15
            font.underline: mouseArea.containsMouse
            readOnly: true
            wrapMode: Text.WordWrap
            selectByMouse: true
            color: Theme.palette.primaryColor1
            text: root.amISender ? qsTr("You") : root.sender.displayName
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                onClicked: {
                    root.clicked(this, mouse)
                }
            }
        }       
        StatusBaseText {
            id: messageOriginInfo
            Layout.alignment: Qt.AlignVCenter
            visible: root.messageOriginInfo !== ""
            color: Theme.palette.baseColor1
            font.pixelSize: 10
            text: root.messageOriginInfo
        }
        StatusContactVerificationIcons {
            visible: !root.amISender
            isContact: root.isContact
            trustIndicator: root.trustIndicator
        }
        StatusBaseText {
            id: secondaryDisplayName
            Layout.alignment: Qt.AlignVCenter
            visible: !root.amISender && !!root.sender.secondaryName
            color: Theme.palette.baseColor1
            font.pixelSize: 10
            text: `(${root.sender.secondaryName})`
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            visible: secondaryDisplayName.visible
            font.pixelSize: 10
            color: Theme.palette.baseColor1
            text: "•"
        }
        StatusBaseText {
            id: tertiaryDetailText
            visible: !root.amISender && messageOriginInfo == ""
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 10
            elide: Text.ElideMiddle
            color: Theme.palette.baseColor1
            text: Utils.elideText(tertiaryDetail, 5, 3)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            visible: tertiaryDetailText.visible
            font.pixelSize: 10
            color: Theme.palette.baseColor1
            text: "•"
        }
        StatusTimeStampLabel {
            id: timestampText
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            color: Theme.palette.dangerColor1
            font.pixelSize: 12
            text: root.resendText
            visible: showResendButton && !!timestampText.text
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: root.resendClicked()
            }
        }
    }
}
