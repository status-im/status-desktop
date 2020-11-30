import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Universal 2.12
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../../Chat/ChatColumn"

ScrollView {
    height: parent.height
    width: parent.width
    id: root
    contentHeight: appearanceContainer.height
    clip: true

    enum Theme {
        Light,
        Dark,
        System
    }

    function updateTheme(theme) {
        let themeStr = Universal.theme === Universal.Dark ? "dark" : "light"
        if (theme === AppearanceContainer.Theme.Light) {
            themeStr = "light"
        } else if (theme === AppearanceContainer.Theme.Dark) {
            themeStr = "dark"
        }
        profileModel.changeTheme(theme)
        Style.changeTheme(themeStr)
    }

    function updateFontSize(fontSize) {
        Style.changeFontSize(fontSize)
    }

    Item {
        id: appearanceContainer
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
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
        }

        Rectangle {
            id: preview
            anchors.top: sectionHeadlinePreview.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            height: 220
            radius: Style.current.radius
            border.color: Style.current.border
            color: Style.current.transparent

            Message {
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding*2
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                userName: "@vitalik"
                identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAb0lEQVR4Ae3UQQqAIBRF0Wj9ba9Bq6l5JBQqfn/ngDMH3YS3AAB/tO3H+XRG3b9bR/+gVoREI2RapVXpfd5+X5oXERKNkHS+rk3tOpWkeREh0QiZVu91ql2zNC8iJBoh0yqtSqt1slpCghICANDPBc0ESPh0bHkHAAAAAElFTkSuQmCC"
                message: qsTr("Blockchains will drop search costs, causing a kind of decomposition that allows you to have markets of entities that are horizontally segregated and vertically segregated.")
                contentType: Constants.messageType
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

        StyledText {
            id: labelFontSize
            anchors.top: sectionHeadlineFontSize.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            font.pixelSize: 15
            text: qsTr("Change font size")
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
                text: qsTr("XS")
                Layout.preferredWidth: fontSizeSlider.width/6
            }

            StyledText {
                font.pixelSize: 15
                text: qsTr("S")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 2
            }

            StyledText {
                font.pixelSize: 15
                text: qsTr("M")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 2
            }

            StyledText {
                font.pixelSize: 15
                text: qsTr("L")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 2
            }

            StyledText {
                font.pixelSize: 15
                text: qsTr("XL")
                Layout.preferredWidth: fontSizeSlider.width/6
                Layout.leftMargin: 0
            }

            StyledText {
                font.pixelSize: 15
                text: qsTr("XXL")
                Layout.alignment: Qt.AlignRight
                Layout.leftMargin: -Style.current.smallPadding
            }
        }

        StatusSectionHeadline {
            id: sectionHeadlineChatMode
            text: qsTr("Chat mode")
            anchors.top: fontSizeSliderLegend.bottom
            anchors.topMargin: Style.current.padding*2
            anchors.left: parent.left
            anchors.right: parent.right
        }

        RowLayout {
            id: chatModeSection
            anchors.top: sectionHeadlineChatMode.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding

            StatusImageRadioButton {
                padding: Style.current.padding
                image.source: "../../../img/appearance-normal-light.svg"
                image.height: 186
                control.text: qsTr("Normal")
                control.checked: !appSettings.compactMode
                control.onCheckedChanged: {
                    if (control.checked) {
                        appSettings.compactMode = false
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.padding
                image.source: "../../../img/appearance-compact-light.svg"
                image.height: 186
                control.text: qsTr("Compact")
                control.checked: appSettings.compactMode
                control.onCheckedChanged: {
                    if (control.checked) {
                        appSettings.compactMode = true
                    }
                }
            }
        }

        StatusSectionHeadline {
            id: sectionHeadlineAppearance
            text: qsTr("Appearance")
            anchors.top: chatModeSection.bottom
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
                image.source: "../../../img/appearance-normal-light.svg"
                image.height: 128
                control.text: qsTr("Light")
                control.checked: profileModel.profile.appearance === AppearanceContainer.Theme.Light
                control.onClicked: {
                    if (control.checked) {
                        root.updateTheme(AppearanceContainer.Theme.Light)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: "../../../img/appearance-normal-dark.svg"
                image.height: 128
                control.text: qsTr("Dark")
                control.checked: profileModel.profile.appearance === AppearanceContainer.Theme.Dark
                control.onClicked: {
                    if (control.checked) {
                        root.updateTheme(AppearanceContainer.Theme.Dark)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: "../../../img/appearance-normal-system.png"
                image.height: 128
                control.text: qsTr("System")
                control.checked: profileModel.profile.appearance === AppearanceContainer.Theme.System
                control.onClicked: {
                    if (control.checked) {
                        root.updateTheme(AppearanceContainer.Theme.System)
                    }
                }
            }

            // For the case where the theme was finally loaded by status-go in init(),
            // update the theme in qml
            Connections {
                target: profileModel
                onProfileChanged: {
                    root.updateTheme(profileModel.profile.appearance)
                }
            }
        }
    }
}
