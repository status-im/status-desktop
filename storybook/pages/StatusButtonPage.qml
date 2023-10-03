import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1

import Storybook 1.0

SplitView {
    Logs { id: logs }

    QtObject {
        id: d
        readonly property var sizesModel: [StatusBaseButton.Size.Tiny, StatusBaseButton.Size.Small, StatusBaseButton.Size.Large]

        readonly property string effectiveEmoji: ctrlEmojiEnabled.checked ? ctrlEmoji.text : ""
        readonly property int effectiveTextPosition: ctrlTextPosLeft.checked ? StatusBaseButton.TextPosition.Left
                                                                             : StatusBaseButton.TextPosition.Right
    }

    SplitView {
        orientation: Qt.Horizontal
        SplitView.fillWidth: true

        Pane {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            GridLayout {
                anchors.centerIn: parent
                rowSpacing: 10
                columnSpacing: 10
                columns: 4

                Label { text: "" }
                Label { text: "Tiny" }
                Label { text: "Small" }
                Label { text: "Large" }

                Label {
                    text: "StatusButton"
                    Layout.columnSpan: 4
                    font.bold: true
                }

                Label { text: "Text only:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        size: modelData
                        text: ctrlText.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label { text: "Icon only:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        size: modelData
                        icon.name: ctrlIconName.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label { text: "Text + icon:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        size: modelData
                        text: ctrlText.text
                        icon.name: ctrlIconName.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label { text: "Round icon:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        Layout.preferredHeight: width
                        size: modelData
                        icon.name: ctrlIconName.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        isRoundIcon: true
                        radius: height/2
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label {
                    text: "StatusFlatButton (no Primary variant)"
                    Layout.columnSpan: 4
                    font.bold: true
                }

                Label { text: "Text only:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusFlatButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        size: modelData
                        text: ctrlText.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label { text: "Icon only:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusFlatButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        size: modelData
                        icon.name: ctrlIconName.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label { text: "Text + icon:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusFlatButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        size: modelData
                        text: ctrlText.text
                        icon.name: ctrlIconName.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        textFillWidth: ctrlFillWidth.checked
                    }
                }

                Label { text: "Round icon:" }
                Repeater {
                    model: d.sizesModel
                    delegate: StatusFlatButton {
                        Layout.preferredWidth: ctrlWidth.value || implicitWidth
                        Layout.preferredHeight: width
                        size: modelData
                        icon.name: ctrlIconName.text
                        asset.emoji: d.effectiveEmoji
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        enabled: ctrlEnabled.checked
                        isRoundIcon: true
                        radius: height/2
                        textFillWidth: ctrlFillWidth.checked
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumWidth: 300
            SplitView.preferredWidth: 400

            logsView.logText: logs.logText

            ColumnLayout {
                width: parent.width
                RowLayout {
                    Label { text: "Text:" }
                    TextField {
                        id: ctrlText
                        placeholderText: "Button text"
                        text: "Foobar"
                    }
                    // enum StatusBaseButton.TextPosition.xxx
                    RadioButton {
                        id: ctrlTextPosLeft
                        text: "left"
                    }
                    RadioButton {
                        id: ctrlTextPosRight
                        text: "right"
                        checked: true
                    }
                }
                RowLayout {
                    Label { text: "Icon name:" }
                    TextField {
                        id: ctrlIconName
                        placeholderText: "Icon name"
                        text: "gif"
                    }
                }
                RowLayout {
                    Label { text: "Emoji:" }
                    TextField {
                        id: ctrlEmoji
                        text: "💩"
                    }
                    CheckBox {
                        id: ctrlEmojiEnabled
                        text: "enabled"
                    }
                }
                RowLayout {
                    Label { text: "Type:" }
                    ComboBox {
                        id: ctrlType
                        model: ["Normal", "Danger", "Primary", "Warning"] // enum StatusBaseButton.Type.xxx
                    }
                }
                RowLayout {
                    Label { text: "Width:" }
                    SpinBox {
                        id: ctrlWidth
                        from: 0
                        to: 280
                        value: 0 // 0 == implicitWidth
                        stepSize: 10
                        textFromValue: function(value, locale) { return value === 0 ? "Implicit" : value }
                    }
                    CheckBox {
                        id: ctrlFillWidth
                        text: "Fill width"
                    }
                }
                Switch {
                    id: ctrlLoading
                    text: "Loading"
                }
                Switch {
                    id: ctrlEnabled
                    text: "Enabled"
                    checked: true
                }
            }
        }
    }
}

// category: Controls

// https://www.figma.com/file/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?type=design&node-id=1-12&t=UHegCbqAa5K7qUKd-0
