import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups
import StatusQ.Controls

import shared.controls

import utils

StatusModal {
    id: root

    required property bool thirdPartyServicesEnabled

    signal toggleThirdpartyServicesEnabled()
    signal openDiscussPageRequested()
    signal openThirdpartyServicesArticleRequested()

    title: qsTr("Third-party services")

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {            
            width: scrollView.availableWidth
            spacing: Theme.padding

            Paragraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Status uses essential third-party services to make your experience more convenient, efficient, and engaging. While only necessary integrations are included, users who prefer to avoid any third-party services can disable them entirely – though this may limit functionality and affect usability")
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height + 2*Theme.padding

                radius: Theme.radius
                border.width: 1
                border.color: Theme.palette.baseColor2
                color: Theme.palette.transparent

                Section {
                    id: section1

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padding
                    anchors.leftMargin: Theme.padding
                    anchors.topMargin: Theme.padding

                    title: qsTr("Features that will be unavailable:")
                    model: ListModel   {
                        ListElement { text: qsTr("Wallet (Swap, Send, Token data, etc.)") }
                        ListElement { text: qsTr("Market (Token data, prices, and news, etc.)") }
                        ListElement { text: qsTr("Token-gated communities and admin tools") }
                        ListElement { text: qsTr("Status news, etc.") }
                    }
                }

                Section {
                    anchors.top: section1.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padding
                    anchors.leftMargin: Theme.padding
                    anchors.topMargin: Theme.padding
                    anchors.bottomMargin: Theme.padding

                    title: qsTr("You may also experience:")
                    model: ListModel   {
                        ListElement { text: qsTr("Missing or invalid data") }
                        ListElement { text: qsTr("Errors and unexpected behavior") }
                    }
                }
            }

            Paragraph {
                Layout.fillWidth: true
                Layout.fillHeight: true

                textFormat: Text.RichText
                text: qsTr("Only disable third-party services if you're aware of the trade-offs. Re-enable them anytime in Settings. Read more details about third-party services %1.")
                .arg(Utils.getStyledLink("in our article", "#", hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
                onLinkActivated: root.openThirdpartyServicesArticleRequested()
                HoverHandler {
                    cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                }
            }

            InformationTag {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                backgroundColor: Theme.palette.primaryColor3
                bgBorderColor: Theme.palette.primaryColor2
                bgRadius: 12
                asset.name: "info"
                tagPrimaryLabel.textFormat: Text.RichText
                tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
                tagPrimaryLabel.text: qsTr("Share feedback or suggest improvements on our %1.")
                .arg(Utils.getStyledLink("Discuss page", "#", tagPrimaryLabel.hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
                tagPrimaryLabel.onLinkActivated: root.openDiscussPageRequested()
            }
        }
    }

    rightButtons: [
        StatusButton {
            type: StatusBaseButton.Type.Primary
            text: root.thirdPartyServicesEnabled ? qsTr("Disable third-party services") : qsTr("Enable third-party services")
            onClicked: {
                root.toggleThirdpartyServicesEnabled()
                root.close()
            }
        },
        StatusButton {
            text: qsTr("Close")
            onClicked: root.close()
        }
    ]

    component Paragraph: StatusBaseText {
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        wrapMode: Text.Wrap
    }

    component Section: ColumnLayout {
        property alias title: titleItem.text
        property alias model: bodyItem.model
        spacing: 8

        Paragraph {
            id: titleItem

            Layout.fillWidth: true
            Layout.fillHeight: true
            font.weight: Font.Bold
        }

        Repeater {
            id: bodyItem

            Layout.fillWidth: true
            delegate: StatusItemDelegate {
                Layout.fillWidth: true
                icon.width: 20
                icon.height: 20
                icon.name: "info"
                icon.color: Theme.palette.dangerColor1
                text: model.text
            }
        }
    }
}
