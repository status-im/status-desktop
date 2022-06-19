import QtQuick 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: root

    property bool editable: true

    // TODO: Use https://github.com/status-im/status-desktop/issues/6136

    input.edit.readOnly: !editable
    label: root.editable ? qsTr("Paste sync code") : qsTr("Sync code")
    input.placeholderText: root.editable ? qsTr("eg. %1").arg("0x2Ef19") : ""
    input.font: Theme.palette.monoFont.name
    input.placeholderFont: input.font
    input.rightComponent: StatusButton {
        size: StatusBaseButton.Size.Tiny
        enabled: root.input.edit.canPaste
        onClicked: {
            if (root.editable) {
                root.input.edit.paste();
                return;
            }

            root.input.edit.selectAll();
            root.input.edit.copy();
            root.input.edit.deselect();
        }

        text: root.editable ? qsTr("Paste") : qsTr("Copy")
    }
}
