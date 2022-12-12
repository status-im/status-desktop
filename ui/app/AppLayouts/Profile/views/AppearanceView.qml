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

    property int currentFontSize: 2
    signal fontSizeChanged(int value)

    property int currentZoom: 2
    signal zoomChanged(int value)

    property int currentTheme: 0
    signal themeChanged(string value)

    function setZoom(value) {
            zoomSlider.value = value
    }

    Item {
        id: appearanceContainer
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        width: appearanceView.contentWidth - 2 * Style.current.padding
        height: childrenRect.height

        ButtonGroup {
            id: chatModeSetting
        }

        ButtonGroup {
            id: appearanceSetting
        }

        Rectangle {
            id: preview
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: placeholderMessage.implicitHeight +
                    placeholderMessage.anchors.leftMargin +
                    placeholderMessage.anchors.rightMargin
            radius: Style.current.radius
            border.color: Style.current.border
            color: Style.current.transparent

            MessageView {
                id: placeholderMessage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Style.current.smallPadding
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
            anchors.topMargin: Style.current.bigPadding*2
            anchors.left: parent.left
            anchors.right: parent.right
        }

        StatusQ.StatusLabeledSlider {
            id: fontSizeSlider
            anchors.top: sectionHeadlineFontSize.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width

            textRole: "name"
            valueRole: "value"
            model: ListModel {
                ListElement { name: qsTr("XS"); value: Theme.FontSizeXS }
                ListElement { name: qsTr("S"); value: Theme.FontSizeS }
                ListElement { name: qsTr("M"); value: Theme.FontSizeM }
                ListElement { name: qsTr("L"); value: Theme.FontSizeL }
                ListElement { name: qsTr("XL"); value: Theme.FontSizeXL }
                ListElement { name: qsTr("XXL"); value: Theme.FontSizeXXL }
            }

            value: currentFontSize

            onCurrentValueChanged: appearanceView.fontSizeChanged(currentValue)
        }

        StatusSectionHeadline {
            id: labelZoom
            anchors.top: fontSizeSlider.bottom
            anchors.topMargin: Style.current.bigPadding*2
            anchors.left: parent.left
            anchors.right: parent.right
            text: qsTr("Zoom (requires restart)")
        }

        StatusQ.StatusLabeledSlider {
            id: zoomSlider

            anchors.top: labelZoom.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            from: 50
            to: 200
            stepSize: 50
            model: [ qsTr("50%"), qsTr("100%"), qsTr("150%"), qsTr("200%") ]

            value: currentZoom
            onValueChanged: { zoomChanged(value) }
        }

        Rectangle {
            id: modeSeparator
            anchors.top: zoomSlider.bottom
            anchors.topMargin: Style.current.padding*3
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Style.current.separator
        }

        StatusSectionHeadline {
            id: sectionHeadlineAppearance
            text: qsTr("Mode")
            anchors.top: modeSeparator.bottom
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
            spacing: Style.current.halfPadding

            StatusImageRadioButton {
                Layout.preferredWidth: parent.width/3 - parent.spacing
                Layout.preferredHeight: implicitHeight
                image.source: Style.png("appearance-light")
                control.text: qsTr("Light")

                control.checked: currentTheme === 0
                onRadioCheckedChanged: { themeChanged(0) }
            }

            StatusImageRadioButton {
                Layout.preferredWidth: parent.width/3 - parent.spacing
                image.source: Style.png("appearance-dark")
                control.text: qsTr("Dark")

                control.checked: currentTheme === 1
                onRadioCheckedChanged: { themeChanged(1) }
            }

            StatusImageRadioButton {
                Layout.preferredWidth: parent.width/3 - parent.spacing
                image.source: Style.png("appearance-system")
                control.text: qsTr("System")

                control.checked: currentTheme === 2
                onRadioCheckedChanged: { themeChanged(2) }
            }
        }
    }
}
