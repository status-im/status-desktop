import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils

import "../panels"
import "../popups"

ActivityNotificationBase {
    id: root

    required property string communityName
    required property string communityColor
    required property string communityImage

    signal openCommunityClicked
    signal openShareAccountsClicked

    bodyComponent: RowLayout {
        spacing: 8

        StatusSmartIdenticon {
            name: root.communityName
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
            Layout.topMargin: 2

            asset {
                width: 24
                height: width
                name: root.communityImage
                color: root.communityColor
                bgWidth: 40
                bgHeight: 40
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop

            RowLayout {
                StatusBaseText {
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Medium
                    font.pixelSize: Theme.primaryTextFontSize
                    wrapMode: Text.WordWrap
                    color: Theme.palette.primaryColor1
                    text: qsTr("%1 requires you to share your Accounts").arg(root.communityName)
                }

                StatusTimeStampLabel {
                    id: timestamp
                    verticalAlignment: Text.AlignVCenter
                    timestamp: root.notification.timestamp
                }
            }

            RowLayout {
                spacing: Theme.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("To continue to be a member of %1, you need to share your accounts").arg(root.communityName)
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: Theme.palette.baseColor1
                }

                StatusFlatButton {
                        size: StatusBaseButton.Size.Small
                        text: qsTr("Share")
                        onClicked: {
                            root.openShareAccountsClicked()
                        }
                    }
            }
        }
    }

    ctaComponent: undefined
}
