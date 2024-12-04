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

    pageClassName: "WelcomePage"
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
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: -headerText.height

            ColumnLayout {
                width: Math.min(400, parent.width)
                spacing: 28
                anchors.centerIn: parent

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
                    Layout.fillWidth: true
                    text: qsTr("Create profile")
                    onClicked: root.createProfileRequested()
                }
                StatusButton {
                    Layout.fillWidth: true
                    text: qsTr("Log in")
                    onClicked: root.loginRequested()
                    normalColor: "transparent"
                    borderWidth: 1
                    borderColor: Theme.palette.baseColor2
                }
                StatusBaseText {
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
                    onLinkActivated: {
                        if (link == "#terms")
                            root.termsOfUseRequested()
                        else if (link == "#privacy")
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            newsModel: d.newsModel
        }
    }
}
