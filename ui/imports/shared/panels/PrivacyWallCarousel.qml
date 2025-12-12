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

    QtObject {
        id: d
        readonly property var window: root.contentItem.Window.window
        readonly property int windowWidth: window ? window.width: Screen.width
        readonly property int windowHeight: window ? window.height: Screen.height
        readonly property bool isSmallPortraitScreen: windowHeight > windowWidth
                                            // The max width of a phone in portrait mode
                                            && windowWidth <= ThemeUtils.portraitBreakpoint.width
        function getImagePath(currentIndex) {
            const imageName = root.model.get(currentIndex).image
            const platformPostfix = isSmallPortraitScreen ? "-small": ""
            const imagePath =  "%1-%2%3".arg(imageName).arg(root.Theme.palette.name).arg(platformPostfix)
            return Assets.png(imagePath)
        }
    }

    verticalPadding: Theme.xlPadding
    horizontalPadding: Theme.xlPadding * 2

    contentItem: ColumnLayout {
        spacing: Theme.bigPadding

        Item { Layout.fillHeight: true }

        ColumnLayout {
            readonly property int maxChildrenHeight: (primaryText.maximumLineCount * primaryText.lineHeight) +
                                                      (secondaryText.maximumLineCount * secondaryText.lineHeight)

            Layout.fillWidth: true
            Layout.preferredHeight: maxChildrenHeight
            Layout.maximumHeight: maxChildrenHeight
            spacing: 0

            Item { Layout.fillHeight: true }

            StatusBaseText {
                id: primaryText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom

                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.Bold
                font.pixelSize: 22
                wrapMode: Text.WordWrap
                lineHeightMode: Text.FixedHeight
                lineHeight: 30
                maximumLineCount: 2

                text: root.model.get(pageIndicator.currentIndex).primary
            }

            StatusBaseText {
                id: secondaryText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom

                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.additionalTextSize
                lineHeightMode: Text.FixedHeight
                lineHeight: 18
                wrapMode: Text.WordWrap
                maximumLineCount: 2

                text: root.model.get(pageIndicator.currentIndex).secondary
            }
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
            source: d.getImagePath(pageIndicator.currentIndex)

            // cross-fade sequence
            SequentialAnimation {
                id: fadeSwap
                OpacityAnimator { target: placeholderImage; from: 1; to: 0; duration: 500;}
                PropertyAction   { target: placeholderImage; property: "source";
                                   value: d.getImagePath(pageIndicator.currentIndex) }
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
                /* In case there is only one image in the list no animation
                handling needed and default boinding will do the job */
                if(pageIndicator.count > 1) {
                    placeholderImage.source = d.getImagePath(pageIndicator.currentIndex)
                    initialized = true
                }
            }
        }

        StatusLoadingPageIndicator {
            id: pageIndicator

            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width

            count: root.model.count
            visible: count > 1
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
            normalColor: Theme.palette.privacyColors.primary
            textColor: Theme.palette.privacyColors.tertiary

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
