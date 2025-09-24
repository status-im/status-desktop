import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Onboarding.components

import utils

OnboardingPage {
    id: root

    required property bool privacyModeFeatureEnabled
    required property bool thirdpartyServicesEnabled

    signal createProfileRequested()
    signal loginRequested()

    signal privacyPolicyRequested()
    signal termsOfUseRequested()
    signal openThirdpartyServicesInfoPopupRequested()

    readonly property bool isPortrait: root.width < root.height && root.width <= root.implicitWidth

    QtObject {
        id: d
        readonly property ListModel newsModel: ListModel {
            ListElement {
                primary: qsTr("Own your crypto")
                secondary: qsTr("Use the leading multi-chain self-custodial wallet")
                image: "onboarding/carousel/crypto"
            }
            ListElement {
                primary: qsTr("Chat privately with friends")
                secondary: qsTr("With full metadata privacy and e2e encryption")
                image: "onboarding/carousel/chat"
            }
            ListElement {
                primary: qsTr("Store your assets on Keycard")
                secondary: qsTr("Be safe with secure cold wallet")
                image: "onboarding/carousel/keycard"
            }
        }
    }

    title: qsTr("Welcome to Status")

    contentItem: GridLayout {
        rows: root.isPortrait ? 2 : 1
        columns: root.isPortrait ? 1 : 2
        uniformCellHeights: true
        uniformCellWidths: true
        layoutDirection: Qt.RightToLeft

        NewsCarousel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            newsModel: d.newsModel
        }
        // left part (welcome + buttons)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(400, parent.width)
                spacing: root.isPortrait ? 6 : 28

                Item { Layout.fillHeight: true } // Spacer

                ColumnLayout {
                    id: logoAndTextLayout
                    Layout.fillWidth: true
                    spacing: root.isPortrait ? 6 : 28
                    StatusImage {
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        source: Theme.png("status")
                        mipmap: true
                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 0
                            verticalOffset: 4
                            radius: 12
                            samples: 25
                            spread: 0.2
                            color: Theme.palette.dropShadow
                        }
                    }

                    StatusBaseText {
                        id: headerText
                        Layout.fillWidth: true
                        text: root.title
                        font.pixelSize: Theme.fontSize40
                        font.bold: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: qsTr("The open-source, decentralised wallet and messenger")
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item { Layout.fillHeight: true } // Spacer

                ColumnLayout {
                    id: buttonsLayout
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: Theme.xlPadding
                    spacing: root.padding
                    StatusButton {
                        objectName: "btnCreateProfile"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignBottom
                        text: qsTr("Create profile")
                        onClicked: root.createProfileRequested()
                    }
                    StatusButton {
                        objectName: "btnLogin"
                        Layout.fillWidth: true
                        text: qsTr("Log in")
                        isOutline: true
                        onClicked: root.loginRequested()
                    }
                    StatusBaseText {
                        objectName: "thirdPartyServices"
                        Layout.fillWidth: true
                        Layout.topMargin: Theme.halfPadding
                        Layout.bottomMargin: Theme.halfPadding
                        text: qsTr("Third-party services %1").arg(
                                  Utils.getStyledLink(root.thirdpartyServicesEnabled ? qsTr("enabled"): qsTr("disabled"),
                                                      "#",
                                                      hoveredLink,
                                                      Theme.palette.primaryColor1,
                                                      Theme.palette.primaryColor1,
                                                      false))
                        textFormat: Text.RichText
                        font.pixelSize: Theme.tertiaryTextFontSize
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 16
                        wrapMode: Text.WordWrap
                        color: Theme.palette.baseColor1
                        horizontalAlignment: Text.AlignHCenter
                        onLinkActivated: root.openThirdpartyServicesInfoPopupRequested()

                        HoverHandler {
                            // Qt CSS doesn't support custom cursor shape
                            cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                        }

                        visible: root.privacyModeFeatureEnabled
                    }
                    StatusBaseText {
                        objectName: "approvalLinks"
                        Layout.fillWidth: true
                        text: qsTr("By proceeding you accept Status<br>%1 and %2")
                            .arg(Utils.getStyledLink(qsTr("Terms of Use"), "#terms", hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
                            .arg(Utils.getStyledLink(qsTr("Privacy Policy"), "#privacy", hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))
                        textFormat: Text.RichText
                        font.pixelSize: Theme.tertiaryTextFontSize
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 16
                        wrapMode: Text.WordWrap
                        color: Theme.palette.baseColor1
                        horizontalAlignment: Text.AlignHCenter
                        onLinkActivated: (link) => {
                            if (link === "#terms")
                                root.termsOfUseRequested()
                            else if (link === "#privacy")
                                root.privacyPolicyRequested()
                        }

                        HoverHandler {
                            // Qt CSS doesn't support custom cursor shape
                            cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                        }
                    }
                }
            }
        }
    }
}
