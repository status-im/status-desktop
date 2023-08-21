import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: root

    // TODO: Use https://github.com/status-im/status-desktop/issues/6136

    enum Mode {
        WriteMode,
        ReadMode
    }

    required property int mode
    property bool readOnly: false

    input.edit.readOnly: root.readOnly
    input.font: Theme.palette.monoFont.name
    input.placeholderFont: root.input.font

    input.rightComponent: {
        switch (root.mode) {
        case StatusSyncCodeInput.Mode.WriteMode:
            return root.valid ? validCodeIconComponent
                              : pasteButtonComponent
        case StatusSyncCodeInput.Mode.ReadMode:
            return copyButtonComponent
        }
    }

    Component {
        id: copyButtonComponent

        StatusButton {
            size: StatusBaseButton.Size.Tiny
            text: qsTr("Copy")
            onClicked: {
                root.input.edit.selectAll();
                root.input.edit.copy();
                root.input.edit.deselect();
            }
        }
    }

    Component {
        id: pasteButtonComponent

        StatusButton {
            size: StatusBaseButton.Size.Tiny
            enabled: !root.readOnly && root.input.edit.canPaste
            text: qsTr("Paste")
            onClicked: {
                root.input.edit.selectAll();
                root.input.edit.paste();
            }
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
