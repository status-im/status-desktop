import QtQuick 2.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property var store

    property bool importingSingleChannel

    title: importingSingleChannel ? qsTr("Import a channel from Discord into Status") :
                                    qsTr("Import a community from Discord into Status")

    horizontalPadding: 16
    verticalPadding: 20
    width: 640

    onClosed: destroy()

    Component.onCompleted: {
        const buttons = contents.rightButtons
        for (let i = 0; i < buttons.length; i++) {
            footer.rightButtons.append(buttons[i])
        }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {}
    }

    background: StatusDialogBackground {
        color: Theme.palette.baseColor4
    }

    DiscordImportProgressContents {
        id: contents
        anchors.fill: parent
        store: root.store
        importingSingleChannel: root.importingSingleChannel
        onClose: root.close()
    }
}
