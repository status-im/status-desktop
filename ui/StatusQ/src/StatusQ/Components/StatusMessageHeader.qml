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
    property double timestamp: 0

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
    property bool showFullTimestamp

    signal clicked(var sender, var mouse)
    signal resendClicked()

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    RowLayout {
        id: layout
        spacing: 4
        width: parent.width
        StatusBaseText {

            id: primaryDisplayName
            Layout.fillWidth: true
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

        Loader {
            id: messageOriginInfoLoader
            active: root.messageOriginInfo
            asynchronous: true
            sourceComponent: StatusBaseText {
                id: messageOriginInfo
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.asideTextFontSize
                text: root.messageOriginInfo
            }
        }

        Loader {
            id: verificationIconsLoader
            active: !root.amISender
            asynchronous: true
            sourceComponent: StatusContactVerificationIcons {
                id: verificationIcons
                isContact: root.isContact
                trustIndicator: root.trustIndicator
            }
        }

        Loader {
            id: secondaryDisplayNameLoader
            active: !root.amISender && !!root.sender.secondaryName
            visible: active
            asynchronous: true
            sourceComponent: StatusBaseText {
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.asideTextFontSize
                text: `(${root.sender.secondaryName})`
            }
        }

        Loader {
            id: dotLoader
            sourceComponent: dotComponent
            active: secondaryDisplayNameLoader.active && tertiaryDetailTextLoader.active
            asynchronous: true
        }

        Loader {
            id: tertiaryDetailTextLoader
            active: !root.amISender && root.messageOriginInfo === "" && !!root.tertiaryDetail
            visible: active
            asynchronous: true
            sourceComponent: StatusBaseText {
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.asideTextFontSize
                visible: text
                elide: Text.ElideMiddle
                color: Theme.palette.baseColor1
                text: Utils.elideText(root.tertiaryDetail, 5, 3)
            }
        }

        Loader {
            id: secondDotLoader
            sourceComponent: dotComponent
            active: verificationIconsLoader.active && verificationIconsLoader.item.width <= 0 || secondaryDisplayNameLoader.active || root.amISender || tertiaryDetailTextLoader.active
            asynchronous: true
        }

        StatusTimeStampLabel {
            verticalAlignment: Text.AlignVCenter
            id: timestampText
            timestamp: root.timestamp
            showFullTimestamp: root.showFullTimestamp
        }

        Loader {
            id: resendButtonLoader
            active: showResendButton && !!timestampText.text
            asynchronous: true
            sourceComponent: StatusBaseText {
                id: resendButton
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.dangerColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                text: root.resendText
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: root.resendClicked()
                }
            }
        }

        Loader {
            id: resendErrorTextLoader
            active: resendError && !!timestampText.text
            asynchronous: true
            sourceComponent: StatusBaseText {
                id: resendErrorText
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                text: qsTr("Failed to resend: %1").arg(resendError) // TODO replace this with the required design
            }
        }

        Loader {
            id: sendingInProgressLoader
            active: showSendingLoader && !!timestampText.text
            asynchronous: true
            sourceComponent: StatusBaseText {
                id: sendingInProgress
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                text: qsTr("Sending...") // TODO replace this with the required design
            }
        }

        Component {
            id: dotComponent
            StatusBaseText {
                id: dot
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.asideTextFontSize
                color: Theme.palette.baseColor1
                text: "•"
            }
        }
    }
}
