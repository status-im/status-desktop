import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1

ColumnLayout {
    id: root

    property string name
    property string chatDateTimeText
    property string listUsersText
    property var messagesModel

    spacing: 0

    // Blur background:
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(
                                    centralPanelData.implicitHeight,
                                    parent.height)

        ColumnLayout {
            id: centralPanelData
            width: parent.width
            layer.enabled: true
            layer.effect: fastBlur

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 30
                Layout.bottomMargin: 30
                text: root.chatDateTimeText
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                StatusBaseText {
                    text: root.listUsersText
                    font.pixelSize: 13
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height + spacing
                Layout.topMargin: 16
                spacing: 16
                model: root.messagesModel
                delegate: StatusMessage {
                    width: ListView.view.width
                    timestamp: model.timestamp
                    enabled: false
                    messageDetails: StatusMessageDetails {
                        messageText: model.message
                        contentType: model.contentType
                        sender.displayName: model.senderDisplayName
                        sender.isContact: model.isContact
                        sender.trustIndicator: model.trustIndicator
                        sender.profileImage: StatusProfileImageSettings {
                            width: 40
                            height: 40
                            name: model.profileImage || ""
                            colorId: model.colorId
                        }
                    }
                }
            }
        }
    }

    // User information content
    Rectangle {
        id: panelBase

        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        gradient: Gradient {
            GradientStop {
                position: 0.000
                color: "transparent"
            }
            GradientStop {
                position: 0.180
                color: panelBase.color
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillHeight: true
            }

            StatusBaseText {
                Layout.maximumWidth: 405
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Bold
                font.pixelSize: Constants.onboarding.titleFontSize
                text: qsTr("%1 will be right back!").arg(root.name)
                wrapMode: Text.WordWrap
            }

            StatusBaseText {
                Layout.maximumWidth: 405
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Constants.onboarding.titleFontSize
                text: qsTr("You will automatically re-enter the community and be able to view and post as normal as soon as the community’s control node comes back online.")
                wrapMode: Text.WordWrap
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Component {
        id: fastBlur

        FastBlur {
            radius: 32
            transparentBorder: true
        }
    }
}
