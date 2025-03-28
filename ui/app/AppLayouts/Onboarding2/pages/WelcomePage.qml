import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.components 1.0

import utils 1.0

OnboardingPage {
    id: root

    title: qsTr("Welcome to Status")

    signal createProfileRequested()
    signal loginRequested()

    signal privacyPolicyRequested()
    signal termsOfUseRequested()

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

    contentItem: RowLayout {
        spacing: root.padding

        // left part (welcome + buttons)
        Item {
            Layout.preferredWidth: root.availableWidth/2 - root.horizontalPadding
            Layout.fillHeight: true

            ColumnLayout {
                width: Math.min(400, parent.width)
                spacing: 28
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -headerText.height/2

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
                    font.pixelSize: 40
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

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.xlPadding
                width: Math.min(320, parent.width)
                spacing: 12

                StatusButton {
                    objectName: "btnCreateProfile"
                    Layout.fillWidth: true
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
                    objectName: "approvalLinks"
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.halfPadding
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


        // right part (news carousel)
        NewsCarousel {
            Layout.preferredWidth: root.availableWidth/2 - root.horizontalPadding
            Layout.fillHeight: true
            newsModel: d.newsModel
        }
    }
}
