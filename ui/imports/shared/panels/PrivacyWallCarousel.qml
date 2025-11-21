import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import utils

Control {
    id: root

    // [{primary:string, secondary:string, image:string}]
    required property var model
    // info text
    required property string infoText

    signal openDiscussPageRequested()
    signal enableThirdpartyServicesRequested()

    verticalPadding: Theme.xlPadding
    horizontalPadding: Theme.xlPadding * 2

    contentItem: ColumnLayout {
        spacing: Theme.bigPadding

        Item { Layout.fillHeight: true }

        StatusBaseText {
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Bold
            font.pixelSize: 22
            lineHeightMode: Text.FixedHeight
            lineHeight: 30
            wrapMode: Text.WordWrap

            text: root.model.get(pageIndicator.currentIndex).primary
        }

        StatusBaseText {
            Layout.topMargin: -parent.spacing
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.additionalTextSize
            lineHeightMode: Text.FixedHeight
            lineHeight: 18
            wrapMode: Text.WordWrap

            text: root.model.get(pageIndicator.currentIndex).secondary
        }

        Image {
            id: placeholderImage

            // Used to onlt start cross fade animation after the first image is set
            property bool initialized: false

            Layout.fillWidth: true
            Layout.maximumWidth: 688
            Layout.fillHeight: true
            Layout.maximumHeight: 368
            Layout.alignment: Qt.AlignHCenter

            fillMode: Image.PreserveAspectFit
            asynchronous: true

            // cross-fade sequence
            SequentialAnimation {
                id: fadeSwap
                OpacityAnimator { target: placeholderImage; from: 1; to: 0; duration: 500;}
                PropertyAction   { target: placeholderImage; property: "source";
                                   value: Assets.png(root.model.get(pageIndicator.currentIndex).image) }
                OpacityAnimator { target: placeholderImage; from: 0; to: 1; duration: 500; }
            }

            // start the animation whenever the index changes
            Connections {
                target: pageIndicator
                function onCurrentIndexChanged() {
                    if(placeholderImage.initialized) {
                        fadeSwap.start()
                    }
                }
            }

            Component.onCompleted: {
                placeholderImage.source = Assets.png(root.model.get(pageIndicator.currentIndex).image)
                initialized = true
            }
        }

        StatusLoadingPageIndicator {
            id: pageIndicator

            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width

            count: root.model.count
        }

        StatusBaseText {
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.additionalTextSize
            wrapMode: Text.WordWrap

            text: root.infoText
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter

            type: StatusBaseButton.Type.Primary
            normalColor: Theme.palette.privacyModeColors.navBarColor
            textColor: Theme.palette.white

            text: qsTr("Enable third-party services")

            onClicked: root.enableThirdpartyServicesRequested()
        }

        Item { Layout.fillHeight: true }

        StatusBaseText {
            Layout.alignment: Qt.AlignBottom
            Layout.fillWidth: true

            textFormat: Text.RichText
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.additionalTextSize
            wrapMode: Text.WordWrap

            text: qsTr("Share feedback or suggest improvements on our %1.")
            .arg(Utils.getStyledLink("Discuss page", "#", hoveredLink, Theme.palette.primaryColor1, Theme.palette.primaryColor1, false))

            onLinkActivated: root.openDiscussPageRequested()
        }
    }
}
