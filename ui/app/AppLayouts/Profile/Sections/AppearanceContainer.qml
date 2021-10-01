import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Universal 2.12

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

//TODO remove import dependency
import "../../Chat/views"

ScrollView {
    height: parent.height
    width: parent.width
    id: root
    contentHeight: appearanceContainer.height
    clip: true
    property var rootStore

    enum Theme {
        Light,
        Dark,
        System
    }

    function updateTheme(theme) {
        globalSettings.theme = theme
        Style.changeTheme(theme, systemPalette.isCurrentSystemThemeDark())
    }

    function updateFontSize(fontSize) {
        Style.changeFontSize(fontSize)
    }

    Item {
        id: appearanceContainer
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter
        height: this.childrenRect.height + 100

        ButtonGroup {
            id: chatModeSetting
        }

        ButtonGroup {
            id: appearanceSetting
        }

        StatusSectionHeadline {
            id: sectionHeadlinePreview
            //% "Preview"
            text: qsTrId("preview")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Rectangle {
            id: preview
            anchors.top: sectionHeadlinePreview.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            height: paceholderMessage.height + Style.current.padding*4
            radius: Style.current.radius
            border.color: Style.current.border
            color: Style.current.transparent

            MessageView {
                id: paceholderMessage
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding*2
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                rootStore: root.rootStore
                messageStore: root.rootStore.messageStore
                Component.onCompleted: {
                    messageStore.userName = "@vitalik";
                    messageStore.identicon = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAb0lEQVR4Ae3UQQqAIBRF0Wj9ba9Bq6l5JBQqfn/ngDMH3YS3AAB/tO3H+XRG3b9bR/+gVoREI2RapVXpfd5+X5oXERKNkHS+rk3tOpWkeREh0QiZVu91ql2zNC8iJBoh0yqtSqt1slpCghICANDPBc0ESPh0bHkHAAAAAElFTkSuQmCC";
                    //% "Blockchains will drop search costs, causing a kind of decomposition that allows you to have markets of entities that are horizontally segregated and vertically segregated."
                    messageStore.message = qsTrId("blockchains-will-drop-search-costs--causing-a-kind-of-decomposition-that-allows-you-to-have-markets-of-entities-that-are-horizontally-segregated-and-vertically-segregated-");
                    messageStore.contentType = Constants.messageType;
                    //messageStore.placeholderMessage = true;
                }
            }
        }

        StatusSectionHeadline {
            id: sectionHeadlineFontSize
            //% "Size"
            text: qsTrId("size")
            anchors.top: preview.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right
        }

        StyledText {
            id: labelFontSize
            anchors.top: sectionHeadlineFontSize.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            font.pixelSize: 15
            //% "Change font size"
            text: qsTrId("change-font-size")
        }

        StatusSlider {
            id: fontSizeSlider
            anchors.top: labelFontSize.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            minimumValue: 0
            maximumValue: 5
            stepSize: 1
            value: appSettings.fontSize
            onValueChanged: {
                appSettings.fontSize = value
                root.updateFontSize(value)
            }
        }

        RowLayout {
            id: fontSizeSliderLegend
            anchors.top: fontSizeSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Style.current.smallPadding

            StyledText {
                font.pixelSize: 15
                //% "XS"
                text: qsTrId("xs")
                Layout.preferredWidth: fontSizeSlider.width/6
            }

            StyledText {
                font.pixelSize: 15
                //% "S"
                text: qsTrId("s")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 2
            }

            StyledText {
                font.pixelSize: 15
                //% "M"
                text: qsTrId("m")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 2
            }

            StyledText {
                font.pixelSize: 15
                //% "L"
                text: qsTrId("l")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 2
            }

            StyledText {
                font.pixelSize: 15
                //% "XL"
                text: qsTrId("xl")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 0
            }

            StyledText {
                font.pixelSize: 15
                //% "XXL"
                text: qsTrId("xxl")
                Layout.alignment: Qt.AlignRight
                Layout.leftMargin: -Style.current.smallPadding
            }
        }

        StyledText {
            id: labelZoom
            anchors.top: fontSizeSliderLegend.bottom
            anchors.topMargin: Style.current.xlPadding
            anchors.left: parent.left
            font.pixelSize: 15
            text: qsTr("Change Zoom (requires restart)")
        }

        StatusSlider {
            id: zoomSlider
            readonly property int initialValue: {
                let scaleFactorStr = utilsModel.readTextFile(uiScaleFilePath)
                if (scaleFactorStr === "") {
                    return 100
                }
                let scaleFactor = parseFloat(scaleFactorStr)
                if (isNaN(scaleFactor)) {
                    return 100
                }
                return scaleFactor * 100
            }
            anchors.top: labelZoom.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            minimumValue: 50
            maximumValue: 200
            stepSize: 50
            value: initialValue
            onValueChanged: {
                if (value !== initialValue) {
                    utilsModel.writeTextFile(uiScaleFilePath, value / 100.0)
                }
            }
            onPressedChanged: {
                if (!pressed && value !== initialValue) {
                    confirmAppRestartModal.open()
                }
            }

            ConfirmAppRestartModal {
                id: confirmAppRestartModal
                onClosed: {
                    zoomSlider.value = zoomSlider.initialValue
                }
            }
        }

        RowLayout {
            id: zoomSliderLegend
            anchors.top: zoomSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            StyledText {
                font.pixelSize: 15
                text: "50%"
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                font.pixelSize: 15
                Layout.leftMargin: width / 2
                text: "100%"
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                font.pixelSize: 15
                Layout.leftMargin: width / 2
                text: "150%"
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                font.pixelSize: 15
                text: "200%"
            }
        }

        // StatusSectionHeadline {
        //     id: sectionHeadlineChatMode
        //     //% "Chat mode"
        //     text: qsTrId("chat-mode")
        //     anchors.top: fontSizeSliderLegend.bottom
        //     anchors.topMargin: Style.current.padding*2
        //     anchors.left: parent.left
        //     anchors.right: parent.right
        // }

        // RowLayout {
        //     id: chatModeSection
        //     anchors.top: sectionHeadlineChatMode.bottom
        //     anchors.topMargin: Style.current.padding
        //     anchors.left: parent.left
        //     anchors.leftMargin: -Style.current.padding
        //     anchors.right: parent.right
        //     anchors.rightMargin: -Style.current.padding

        //     StatusImageRadioButton {
        //         padding: Style.current.padding
        //         image.source: Style.svg("appearance-normal-light")
        //         image.height: 186
        //         //% "Normal"
        //         control.text: qsTrId("normal")
        //         control.checked: !appSettings.useCompactMode
        //         onRadioCheckedChanged: {
        //             if (checked) {
        //                 appSettings.useCompactMode = false
        //             }
        //         }
        //     }

        //     StatusImageRadioButton {
        //         padding: Style.current.padding
        //         image.source: Style.svg("appearance-compact-light")
        //         image.height: 186
        //         //% "Compact"
        //         control.text: qsTrId("compact")
        //         control.checked: appSettings.useCompactMode
        //         onRadioCheckedChanged: {
        //             if (checked) {
        //                 appSettings.useCompactMode = true
        //             }
        //         }
        //     }
        // }

        StatusSectionHeadline {
            id: sectionHeadlineAppearance
            //% "Appearance"
            text: qsTrId("appearance")
            // anchors.top: chatModeSection.bottom
            anchors.top: zoomSliderLegend.bottom
            anchors.topMargin: Style.current.padding*3
            anchors.left: parent.left
            anchors.right: parent.right
        }

        RowLayout {
            id: appearanceSection
            anchors.top: sectionHeadlineAppearance.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: Style.svg("appearance-normal-light")
                image.height: 128
                //% "Light"
                control.text: qsTrId("light")
                control.checked: globalSettings.theme === Universal.Light
                onRadioCheckedChanged: {
                    if (checked) {
                        root.updateTheme(Universal.Light)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: Style.svg("appearance-normal-dark")
                image.height: 128
                //% "Dark"
                control.text: qsTrId("dark")
                control.checked: globalSettings.theme === Universal.Dark
                onRadioCheckedChanged: {
                    if (checked) {
                        root.updateTheme(Universal.Dark)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: Style.svg("appearance-normal-system")
                image.height: 128
                //% "System"
                control.text: qsTrId("system")
                control.checked: globalSettings.theme === Universal.System
                onRadioCheckedChanged: {
                    if (checked) {
                        root.updateTheme(Universal.System)
                    }
                }
            }
        }
    }
}
