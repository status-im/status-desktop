import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

ColumnLayout {
    id: root

    property string title
    property int selectedState: MockedKeycardReaderStateSelector.State.NoReader

    enum State {
        NoReader,
        NoKeycard,
        KeycardInserted
    }

    QtObject {
        id: d

        readonly property string readerStateReaderUnplugged: qsTr("Reader Unplugged")
        readonly property string readerStateKeycardNotInserted: qsTr("Keycard Not Inserted")
        readonly property string readerStateKeycardInserted: qsTr("Keycard Inserted")
    }

    StatusBaseText {
        text: root.title
    }

    StatusButton {
        id: selectReaderStateButton

        text: {
            switch (root.selectedState) {
            case MockedKeycardReaderStateSelector.State.NoReader:
                return d.readerStateReaderUnplugged
            case MockedKeycardReaderStateSelector.State.NoKeycard:
                return d.readerStateKeycardNotInserted
            case MockedKeycardReaderStateSelector.State.KeycardInserted:
                return d.readerStateKeycardInserted
            }

            return ""
        }

        icon.name: "chevron-down"

        onClicked: {
            if (initialReaderState.opened) {
                initialReaderState.close()
            } else {
                initialReaderState.popup(selectReaderStateButton.x, selectReaderStateButton.y + selectReaderStateButton.height + 8)
            }
        }
    }

    StatusMenu {
        id: initialReaderState
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        StatusAction {
            text: d.readerStateReaderUnplugged
            objectName: "readerStateReaderUnpluggedAction"
            onTriggered: {
                root.selectedState = MockedKeycardReaderStateSelector.State.NoReader
            }
        }

        StatusAction {
            text: d.readerStateKeycardNotInserted
            objectName: "readerStateKeycardNotInsertedAction"
            onTriggered: {
                root.selectedState = MockedKeycardReaderStateSelector.State.NoKeycard
            }
        }

        StatusAction {
            text: d.readerStateKeycardInserted
            objectName: "readerStateKeycardInsertedAction"
            onTriggered: {
                root.selectedState = MockedKeycardReaderStateSelector.State.KeycardInserted
            }
        }
    }
}
