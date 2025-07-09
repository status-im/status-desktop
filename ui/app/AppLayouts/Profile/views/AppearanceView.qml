import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared
import shared.views
import shared.status
import shared.views.chat

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls as StatusQ

SettingsContentBase {
    id: root

    required property int theme // Theme.Style.xxx
    required property int fontSize // Theme.FontSize.xxx

    signal themeChangeRequested(int theme)
    signal fontSizeChangeRequested(int fontSize)

    Item {
        id: appearanceContainer
        anchors.left: !!parent ? parent.left : undefined
        anchors.leftMargin: Theme.padding
        width: root.contentWidth - 2 * Theme.padding
        height: childrenRect.height

        Rectangle {
            id: preview
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: placeholderMessage.implicitHeight +
                    placeholderMessage.anchors.leftMargin +
                    placeholderMessage.anchors.rightMargin
            radius: Theme.radius
            border.color: Theme.palette.border
            color: Theme.palette.transparent

            MessageView {
                id: placeholderMessage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.smallPadding
                isMessage: true
                shouldRepeatHeader: true
                messageTimestamp: Date.now()
                senderDisplayName: "vitalik.eth"
                senderIcon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAb0lEQVR4Ae3UQQqAIBRF0Wj9ba9Bq6l5JBQqfn/ngDMH3YS3AAB/tO3H+XRG3b9bR/+gVoREI2RapVXpfd5+X5oXERKNkHS+rk3tOpWkeREh0QiZVu91ql2zNC8iJBoh0yqtSqt1slpCghICANDPBc0ESPh0bHkHAAAAAElFTkSuQmCC"
                messageText: qsTr("Blockchains will drop search costs, causing a kind of decomposition that allows you to have markets of entities that are horizontally segregated and vertically segregated.")
                messageContentType: Constants.messageContentType.messageType
                placeholderMessage: true
            }
        }

        StatusSectionHeadline {
            id: sectionHeadlineFontSize
            text: qsTr("Text size")
            anchors.top: preview.bottom
            anchors.topMargin: Theme.bigPadding*2
            anchors.left: parent.left
            anchors.right: parent.right
        }

        StatusQ.StatusLabeledSlider {
            id: fontSizeSlider
            anchors.top: sectionHeadlineFontSize.bottom
            anchors.topMargin: Theme.padding
            width: parent.width

            textRole: "name"
            valueRole: "value"
            model: ListModel {
                ListElement { name: qsTr("XS"); value: Theme.FontSize.FontSizeXS }
                ListElement { name: qsTr("S"); value: Theme.FontSize.FontSizeS }
                ListElement { name: qsTr("M"); value: Theme.FontSize.FontSizeM }
                ListElement { name: qsTr("L"); value: Theme.FontSize.FontSizeL }
                ListElement { name: qsTr("XL"); value: Theme.FontSize.FontSizeXL }
                ListElement { name: qsTr("XXL"); value: Theme.FontSize.FontSizeXXL }
            }

            value: root.fontSize

            onMoved: root.fontSizeChangeRequested(value)
        }

        Rectangle {
            id: modeSeparator
            anchors.top: fontSizeSlider.bottom
            anchors.topMargin: Theme.padding*3
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Theme.palette.separator
        }

        StatusSectionHeadline {
            id: sectionHeadlineAppearance
            text: qsTr("Mode")
            anchors.top: modeSeparator.bottom
            anchors.topMargin: Theme.padding*3
            anchors.left: parent.left
            anchors.right: parent.right
        }

        RowLayout {
            id: appearanceSection
            anchors.top: sectionHeadlineAppearance.bottom
            anchors.topMargin: Theme.padding
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.halfPadding

            StatusImageRadioButton {
                Layout.preferredWidth: parent.width/3 - parent.spacing
                Layout.preferredHeight: implicitHeight
                image.source: Theme.png("appearance-light")
                control.text: qsTr("Light")
                control.checked: root.theme === Theme.Style.Light
                onRadioCheckedChanged: function(checked) {
                    if (checked) {
                        root.themeChangeRequested(Theme.Style.Light)
                    }
                }
            }

            StatusImageRadioButton {
                Layout.preferredWidth: parent.width/3 - parent.spacing
                image.source: Theme.png("appearance-dark")
                control.text: qsTr("Dark")
                control.checked: root.theme === Theme.Style.Dark
                onRadioCheckedChanged: function(checked) {
                    if (checked) {
                        root.themeChangeRequested(Theme.Style.Dark)
                    }
                }
            }

            StatusImageRadioButton {
                Layout.preferredWidth: parent.width/3 - parent.spacing
                image.source: Theme.png("appearance-system")
                control.text: qsTr("System")
                control.checked: root.theme === Theme.Style.System
                onRadioCheckedChanged: function(checked) {
                    if (checked) {
                        root.themeChangeRequested(Theme.Style.System)
                    }
                }
            }
        }
    }
}
