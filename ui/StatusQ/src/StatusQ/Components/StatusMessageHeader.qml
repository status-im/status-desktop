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
    property string resendError: ""
    property bool isContact: sender.isContact
    property int trustIndicator: sender.trustIndicator
    property bool amISender: false
    property bool displayNameClickable: true
    property string messageOriginInfo: ""
    property bool showFullTimestamp
    property int outgoingStatus: StatusMessage.OutgoingStatus.Unknown
    property bool showOutgointStatusLabel: false

    signal clicked(var sender, var mouse)
    signal resendClicked()

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    QtObject {
        id: d

        readonly property bool expired: root.outgoingStatus === StatusMessage.OutgoingStatus.Expired
        readonly property color outgoingStatusColor: expired ? Theme.palette.warningColor1 : Theme.palette.baseColor1
    }

    RowLayout {
        id: layout
        spacing: 4
        width: parent.width

        StatusBaseText {
            id: primaryDisplayName
            objectName: "StatusMessageHeader_DisplayName"
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: Math.ceil(implicitWidth)
            Layout.bottomMargin: 2 // offset for the underline to stay vertically centered
            font.weight: Font.Medium
            font.underline: mouseArea.containsMouse
            font.pixelSize: Theme.primaryTextFontSize
            wrapMode: Text.WordWrap
            color: Theme.palette.primaryColor1
            text: root.amISender ? qsTr("You") : Emoji.parse(root.sender.displayName)
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
                text: Utils.elideText(root.tertiaryDetail, 3, 6)
            }
        }

        Loader {
            id: secondDotLoader
            sourceComponent: dotComponent
            active: verificationIconsLoader.active && verificationIconsLoader.item.width <= 0 || secondaryDisplayNameLoader.active || root.amISender || tertiaryDetailTextLoader.active
            asynchronous: true
        }

        StatusTimeStampLabel {
            id: timestampText
            verticalAlignment: Text.AlignVCenter
            timestamp: root.timestamp
            showFullTimestamp: root.showFullTimestamp
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

        Loader {
            id: deliveryStatusLoader
            Layout.alignment: Qt.AlignVCenter
            active: root.outgoingStatus !== StatusMessage.OutgoingStatus.Unknown
            asynchronous: true
            sourceComponent: RowLayout {
                spacing: 0
                StatusIcon {
                    Layout.preferredHeight: 15
                    Layout.preferredWidth: 15
                    Layout.alignment: Qt.AlignVCenter
                    color: d.outgoingStatusColor
                    icon: {
                        if (root.resendError != "")
                            return "tiny/tiny-exclamation"
                        switch (root.outgoingStatus) {
                        case StatusMessage.OutgoingStatus.Delivered:
                            return "tiny/message/delivered"
                        case StatusMessage.OutgoingStatus.Sent:
                            return "tiny/message/sent"
                        case StatusMessage.OutgoingStatus.Sending:
                            return "tiny/pending"
                        case StatusMessage.OutgoingStatus.Expired:
                            return "tiny/tiny-exclamation"
                        default:
                            return ""
                        }
                    }
                }
                Loader {
                    active: root.showOutgointStatusLabel
                    asynchronous: true
                    sourceComponent: StatusBaseText {
                        Layout.alignment: Qt.AlignVCenter
                        color: d.outgoingStatusColor
                        font.pixelSize: Theme.asideTextFontSize
                        text: {
                            if (root.resendError != "")
                                return qsTr("Failed to resend: %1").arg(root.resendError)
                            switch (root.outgoingStatus) {
                            case StatusMessage.OutgoingStatus.Delivered:
                                return qsTr("Delivered")
                            case StatusMessage.OutgoingStatus.Sent:
                                return qsTr("Sent")
                            case StatusMessage.OutgoingStatus.Sending:
                                return qsTr("Sending")
                            case StatusMessage.OutgoingStatus.Expired:
                                return qsTr("Sending failed")
                            default:
                                return ""
                            }
                        }
                    }
                }
            }
        }

        Loader {
            id: resendButtonLoader
            active: root.showOutgointStatusLabel && d.expired
            asynchronous: true
            sourceComponent: StatusButton {
                Layout.fillHeight: true
                verticalPadding: 1
                horizontalPadding: 5
                size: StatusBaseButton.Tiny
                type: StatusBaseButton.Warning
                font.pixelSize: 9
                text: qsTr("Resend")
                onClicked: root.resendClicked()
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
