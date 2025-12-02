import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Popups
import StatusQ.Popups.Dialog
import StatusQ.Components
import StatusQ.Core.Theme

import utils

StatusModal {
    id: root

    property string placement: Constants.metricsEnablePlacement.unknown

    signal setMetricsEnabledRequested(bool enabled)

    width: 640
    title: qsTr("Help us improve Status")
    hasCloseButton: true
    verticalPadding: 20

    closePolicy: Popup.CloseOnEscape

    component Paragraph: StatusBaseText {
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        visible: true
        wrapMode: Text.Wrap
    }

    component AgreementSection: ColumnLayout {
        property alias title: titleItem.text
        property alias body: bodyItem.text
        spacing: 8
        Paragraph {
            id: titleItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.weight: Font.Bold
        }

        Paragraph {
            id: bodyItem
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            id: layout
            width: scrollView.availableWidth
            spacing: 20

            Paragraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Collecting usage data helps us improve Status.")
            }

            AgreementSection {
                title: qsTr("What we will receive:")
                body: qsTr(" •  IP address
 •  Universally Unique Identifiers of device
 •  Logs of actions within the app, including button presses and screen visits")
            }

            AgreementSection {
                title: qsTr("What we won’t receive:")
                body: qsTr(" •  Your profile information
 •  Your addresses
 •  Information you input and send")
            }

            Paragraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                textFormat: Text.RichText
                text: qsTr("Usage data will be shared from all profiles added to device. %1 %2")
                      .arg(root.placement !== Constants.metricsEnablePlacement.privacyAndSecurity ? qsTr("Sharing usage data can be turned off anytime in Settings / Privacy and Security.") : "")
                      .arg(root.placement === Constants.metricsEnablePlacement.privacyAndSecurity ? qsTr("For more details refer to our %1.").arg(Utils.getStyledLink("Privacy Policy", "#", hoveredLink, Theme.palette.directColor1, Theme.palette.primaryColor1)) : "")
                onLinkActivated: {
                    root.close()
                    Global.privacyPolicyRequested()
                }
                HoverHandler {
                    cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                }
            }
        }
    }

    rightButtons: [
        StatusFlatButton {
            text: qsTr("Do not share")
            onClicked: {
                root.setMetricsEnabledRequested(false)
                close()
            }
            objectName: "notShareMetricsButton"
            normalColor: "transparent"
        },
        StatusButton {
            text: qsTr("Share usage data")
            onClicked: {
                root.setMetricsEnabledRequested(true)
                close()
            }
            objectName: "shareMetricsButton"
        }
    ]
}
