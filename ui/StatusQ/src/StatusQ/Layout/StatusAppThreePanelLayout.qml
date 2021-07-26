import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Core.Theme 0.1

SplitView {
    id: root

    implicitWidth: 822
    implicitHeight: 600

    handle: Item { }

    property Item leftPanel
    property Item centerPanel
    property Component rightPanel
    property bool showRightPanel

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
        SplitView.fillHeight: true
        contentItem: (!!leftPanel) ? leftPanel : null
        background: Rectangle {
            anchors.fill: parent
            color: Theme.palette.baseColor4
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        contentItem: (!!centerPanel) ? centerPanel : null
        background: Rectangle {
            anchors.fill: parent
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        }
    }

    Control {
        SplitView.preferredWidth: root.showRightPanel ? 250 : 0
        SplitView.minimumWidth: root.showRightPanel ? 50 : 0
        opacity: root.showRightPanel ? 1.0 : 0.0
        visible: (opacity > 0.1)
        contentItem: Loader {
            anchors.fill: parent
            sourceComponent: (!!rightPanel) ? rightPanel : null
        }
        background: Rectangle {
            anchors.fill: parent
            color: Theme.palette.baseColor4
        }
    }
}
