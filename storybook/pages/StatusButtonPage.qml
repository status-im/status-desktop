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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
                        textFillWidth: ctrlFillWidth.checked
                        isOutline: ctrlIsOutline.checked
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
                        textFillWidth: ctrlFillWidth.checked
                        isOutline: ctrlIsOutline.checked
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
                        textFillWidth: ctrlFillWidth.checked
                        isOutline: ctrlIsOutline.checked
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
                        isRoundIcon: true
                        textFillWidth: ctrlFillWidth.checked
                        isOutline: ctrlIsOutline.checked
                    }
                }

                Label {
                    text: "StatusFlatButton"
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
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
                        tooltip.text: ctrlTooltip.text
                        textPosition: d.effectiveTextPosition
                        type: ctrlType.currentIndex
                        loading: ctrlLoading.checked
                        loadingWithText: ctrlLoadingWithText.checked
                        enabled: ctrlEnabled.checked
                        interactive: ctrlInteractive.checked
                        isRoundIcon: true
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
                    Label { text: "Tooltip:" }
                    TextField {
                        id: ctrlTooltip
                        placeholderText: "Tooltip"
                        text: "Sample tooltip"
                    }
                }
                RowLayout {
                    Label { text: "Type:" }
                    ComboBox {
                        id: ctrlType
                        model: ["Normal", "Danger", "Primary", "Warning", "Success"] // enum StatusBaseButton.Type.xxx
                    }
                    CheckBox {
                        id: ctrlIsOutline
                        text: "isOutline"
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
                    id: ctrlLoadingWithText
                    text: "Loading with text"
                }
                Switch {
                    id: ctrlInteractive
                    text: "Interactive"
                    checked: true
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
// status: good
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-5905&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-5906&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-5612&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-5613&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-4920&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-4921&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-5328&m=dev
// https://www.figma.com/design/MtAO3a7HnEH5xjCDVNilS7/%F0%9F%8E%A8-Design-System-%E2%8E%9C-Desktop?node-id=1029-5329&m=dev
