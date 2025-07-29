import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

ColumnLayout {
    spacing: 8
    width: parent.width

    readonly property int leftPanelMaxWidth: 308 // It fits on mobile / portrait + desktop left panel

    readonly property QtObject notificationBaseMock: QtObject {
        readonly property string id: "notificationID-111"
        readonly property string title: title.text
        readonly property string description: desc.text
        readonly property double timestamp: timestamp.text
        readonly property double previousTimestamp: 0
        readonly property bool read: read.checked
        readonly property bool dismissed: dismissed.checked
        readonly property bool accepted: accepted.checked
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 8
        text: "Title:"
        font.weight: Font.Bold
    }

    TextField {
        id: title
        Layout.fillWidth: true
        text: "Some title"
    }

    Label {
        Layout.topMargin: 8
        Layout.fillWidth: true
        text: "Description:"
        font.weight: Font.Bold
    }

    TextField {
        id: desc
        Layout.fillWidth: true
        text: "Some notification description"
    }

    Label {
        Layout.topMargin: 8
        Layout.fillWidth: true
        text: "Timestamp:"
        font.weight: Font.Bold
    }

    TextField {
        id: timestamp
        Layout.fillWidth: true
        text: Date.now()
    }

    Label {
        Layout.topMargin: 8
        Layout.fillWidth: true
        text: "Notification Status:"
        font.weight: Font.Bold
    }

    ButtonGroup { id: read_dismissed_accepted }

    RadioButton {
        id: read
        Layout.fillWidth: true
        text: "Read"
    }

    RadioButton {
        id: dismissed
        Layout.fillWidth: true
        text: "Dismissed"
        checked: true
    }

    RadioButton {
        id: accepted
        Layout.fillWidth: true
        text: "Accepted"
    }
}
