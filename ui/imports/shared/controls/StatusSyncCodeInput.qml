import QtQuick

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

StatusInput {
    id: root

    // TODO: Use https://github.com/status-im/status-app/issues/6136

    enum Mode {
        WriteMode,
        ReadMode
    }

    required property int mode
    property bool readOnly: false

    input.edit.readOnly: root.readOnly
    input.font: Theme.monoFont.name
    input.placeholderFont: root.input.font

    input.rightComponent: {
        switch (root.mode) {
        case StatusSyncCodeInput.Mode.WriteMode:
            return root.valid ? validCodeIconComponent
                              : ClipboardUtils.hasText ? pasteButtonComponent : null
        case StatusSyncCodeInput.Mode.ReadMode:
            return copyButtonComponent
        }
    }
    rightPadding: 12

    Component {
        id: copyButtonComponent

        StatusButton {
            objectName: "syncCodeCopyButton"
            size: StatusBaseButton.Size.Tiny
            text: qsTr("Copy")
            onClicked: ClipboardUtils.setText(root.text)
        }
    }

    Component {
        id: pasteButtonComponent

        StatusButton {
            objectName: "syncCodePasteButton"
            size: StatusBaseButton.Size.Tiny
            enabled: !root.readOnly && ClipboardUtils.hasText
            text: qsTr("Paste")
            onClicked: root.input.text = ClipboardUtils.text
        }
    }

    Component {
        id: validCodeIconComponent

        StatusIcon {
            icon: "tiny/checkmark"
            color: Theme.palette.successColor1
        }
    }
}
