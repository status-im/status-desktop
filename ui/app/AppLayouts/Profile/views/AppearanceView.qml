import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Universal 2.12

import utils 1.0
import shared 1.0
import shared.views 1.0
import shared.status 1.0
import shared.views.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQ

import "../popups"
import "../stores"

SettingsContentBase {
    id: appearanceView

    property AppearanceStore appearanceStore

    property var systemPalette

    enum Theme {
        Light,
        Dark,
        System
    }

    function updateTheme(theme) {
        localAppSettings.theme = theme
        Style.changeTheme(theme, systemPalette.isCurrentSystemThemeDark())
    }

    function updateFontSize(fontSize) {
        Style.changeFontSize(fontSize)
    }

    Component.onCompleted: {
        appearanceView.updateFontSize(localAccountSensitiveSettings.fontSize)
    }

    Item {
        id: appearanceContainer
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        width: appearanceView.contentWidth - 2 * Style.current.padding
        height: this.childrenRect.height + 100

        ButtonGroup {
            id: chatModeSetting
        }

        ButtonGroup {
            id: appearanceSetting
        }

        StatusSectionHeadline {
            id: sectionHeadlinePreview
            text: qsTr("Preview")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 0
        }

        Rectangle {
            id: preview
            anchors.top: sectionHeadlinePreview.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right
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
                isMessage: true
                shouldRepeatHeader: true
                messageTimestamp:Date.now()
                senderDisplayName: "@vitalik"
                senderIcon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAb0lEQVR4Ae3UQQqAIBRF0Wj9ba9Bq6l5JBQqfn/ngDMH3YS3AAB/tO3H+XRG3b9bR/+gVoREI2RapVXpfd5+X5oXERKNkHS+rk3tOpWkeREh0QiZVu91ql2zNC8iJBoh0yqtSqt1slpCghICANDPBc0ESPh0bHkHAAAAAElFTkSuQmCC"
                message: qsTr("Blockchains will drop search costs, causing a kind of decomposition that allows you to have markets of entities that are horizontally segregated and vertically segregated.")
                messageContentType: Constants.messageContentType.messageType
                placeholderMessage: true
            }
        }

        StatusSectionHeadline {
            id: sectionHeadlineFontSize
            text: qsTr("Size")
            anchors.top: preview.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right
        }

        StatusBaseText {
            id: labelFontSize
            anchors.top: sectionHeadlineFontSize.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            font.pixelSize: 15
            text: qsTr("Change font size")
            color: Theme.palette.directColor1
        }

        StatusQ.StatusLabeledSlider {
            id: fontSizeSlider
            anchors.top: labelFontSize.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            model: [ qsTr("XS"), qsTr("S"), qsTr("M"), qsTr("L"), qsTr("XL"), qsTr("XXL") ]
            value: localAccountSensitiveSettings.fontSize
            onValueChanged: {
                if (localAccountSensitiveSettings.fontSize !== value) {
                    localAccountSensitiveSettings.fontSize = value
                    appearanceView.updateFontSize(value)
                }
            }
        }

        StatusBaseText {
            id: labelZoom
            anchors.top: fontSizeSlider.bottom
            anchors.topMargin: Style.current.xlPadding
            anchors.left: parent.left
            font.pixelSize: 15
            text: qsTr("Change Zoom (requires restart)")
            color: Theme.palette.directColor1
        }

        StatusQ.StatusLabeledSlider {
            id: zoomSlider
            readonly property int initialValue: {
                let scaleFactorStr = appearanceView.appearanceStore.readTextFile(uiScaleFilePath)
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
            from: 50
            to: 200
            stepSize: 50
            model: [ qsTr("50%"), qsTr("100%"), qsTr("150%"), qsTr("200%") ]
            value: initialValue
            onValueChanged: {
                if (value !== initialValue) {
                    appearanceView.appearanceStore.writeTextFile(uiScaleFilePath, value / 100.0)
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

        StatusSectionHeadline {
            id: sectionHeadlineAppearance
            text: qsTr("Appearance")
            // anchors.top: chatModeSection.bottom
            anchors.top: zoomSlider.bottom
            anchors.topMargin: Style.current.padding*3
            anchors.left: parent.left
            anchors.right: parent.right
        }

        RowLayout {
            id: appearanceSection
            anchors.top: sectionHeadlineAppearance.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: Style.png("appearance-light")
                image.height: 128
                control.text: qsTr("Light")
                control.checked: localAppSettings.theme === Universal.Light
                onRadioCheckedChanged: {
                    if (checked) {
                        appearanceView.updateTheme(Universal.Light)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: Style.png("appearance-dark")
                image.height: 128
                control.text: qsTr("Dark")
                control.checked: localAppSettings.theme === Universal.Dark
                onRadioCheckedChanged: {
                    if (checked) {
                        appearanceView.updateTheme(Universal.Dark)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: Style.png("appearance-system")
                image.height: 128
                control.text: qsTr("System")
                control.checked: localAppSettings.theme === Universal.System
                onRadioCheckedChanged: {
                    if (checked) {
                        appearanceView.updateTheme(Universal.System)
                    }
                }
            }
        }
    }
}
