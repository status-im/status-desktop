import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Onboarding2.controls 1.0

import utils 1.0

OnboardingPage {
    id: root

    title: qsTr("Help us improve Status")

    signal shareUsageDataRequested(bool enabled)
    signal privacyPolicyRequested()

    pageClassName: "HelpUsImproveStatusPage"

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(320, root.availableWidth)
            spacing: root.padding
            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Your usage data helps us make Status better")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusImage {
                Layout.preferredWidth: 320
                Layout.preferredHeight: 320
                Layout.topMargin: 36
                Layout.bottomMargin: 36
                Layout.alignment: Qt.AlignHCenter
                mipmap: true
                source: Theme.png("onboarding/status_totebag_artwork_1")
            }

            StatusButton {
                Layout.fillWidth: true
                text: qsTr("Share usage data")
                onClicked: root.shareUsageDataRequested(true)
            }
            StatusButton {
                Layout.fillWidth: true
                text: qsTr("Not now")
                normalColor: "transparent"
                borderWidth: 1
                borderColor: Theme.palette.baseColor2
                onClicked: root.shareUsageDataRequested(false)
            }
        }
    }

    StatusButton {
        width: 32
        height: 32
        icon.width: 20
        icon.height: 20
        icon.color: Theme.palette.directColor1
        normalColor: Theme.palette.baseColor2
        padding: 0
        anchors.right: parent.right
        anchors.top: parent.top
        icon.name: "info"
        onClicked: helpUsImproveDetails.createObject(root).open()
    }

    Component {
        id: helpUsImproveDetails
        StatusDialog {
            title: qsTr("Help us improve Status")
            width: 480
            standardButtons: Dialog.Ok
            padding: 20
            destroyOnClose: true
            contentItem: ColumnLayout {
                spacing: 20
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("We’ll collect anonymous analytics and diagnostics from your app to enhance Status’s quality and performance.")
                    wrapMode: Text.WordWrap
                }
                OnboardingFrame {
                    Layout.fillWidth: true
                    dropShadow: false
                    contentItem: ColumnLayout {
                        spacing: 12
                        BulletPoint {
                            text: qsTr("Gather basic usage data, like clicks and page views")
                            check: true
                        }
                        BulletPoint {
                            text: qsTr("Gather core diagnostics, like bandwidth usage")
                            check: true
                        }
                        BulletPoint {
                            text: qsTr("Never collect your profile information or wallet address")
                        }
                        BulletPoint {
                            text: qsTr("Never collect information you input or send")
                        }
                        BulletPoint {
                            text: qsTr("Never sell your usage analytics data")
                        }
                    }
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("For more details and other cases where we handle your data, refer to our %1.")
                      .arg(Utils.getStyledLink(qsTr("Privacy Policy"), "#privacy", hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    onLinkActivated: {
                        if (link == "#privacy") {
                            close()
                            root.privacyPolicyRequested()
                        }
                    }
                    HoverHandler {
                        // Qt CSS doesn't support custom cursor shape
                        cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                    }
                }
            }
        }
    }

    component BulletPoint: RowLayout {
        property string text
        property bool check

        spacing: 6
        StatusIcon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            icon: parent.check ? "check-circle" : "close-circle"
            color: parent.check ? Theme.palette.successColor1 : Theme.palette.dangerColor1
        }
        StatusBaseText {
            Layout.fillWidth: true
            text: parent.text
            font.pixelSize: Theme.additionalTextSize
        }
    }
}
