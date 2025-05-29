import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Layout 0.1

Page {
    id: root

    header: ToolBar {
        id: toolbar
        width: parent.width
        Flow {
            anchors.fill: parent
            spacing: 5
            ComboBox {
                id: layoutChooser
                model: ["landscape", "portrait"]
                currentIndex: 0
            }
            CheckBox {
                id: leftPanelCheckBox
                text: "Show Left Panel"
                checked: true
            }
            CheckBox {
                id: centerPanelCheckBox
                text: "Show Center Panel"
                checked: true
            }
            CheckBox {
                id: rightPanelCheckBox
                text: "Show Right Panel"
                checked: true
            }
            Button {
                text: "Next Panel"
                onClicked: sectionLayout.goToNextPanel()
            }
        }
    }

    Page {
        id: leftPanel
        objectName: "leftPanel"
        title: "Left Panel"
        implicitWidth: 200
        implicitHeight: 400
        Rectangle {
            color: "red"
            anchors.fill: parent
        }
        Label {
            text: "This is the left panel"
            anchors.centerIn: parent
        }
    }

    Page {
        id: centerPanel
        objectName: "centerPanel"
        title: "Center Panel"
        implicitWidth: 400
        implicitHeight: 400
        Rectangle {
            color: "blue"
            anchors.fill: parent
        }
        Label {
            text: "This is the center panel"
            anchors.centerIn: parent
        }
    }
    Page {
        id: rightPanel
        title: "Right Panel"
        implicitWidth: 200
        implicitHeight: 400
        Rectangle {
            color: "green"
            anchors.fill: parent
        }
        Label {
            text: "This is the right panel"
            anchors.centerIn: parent
        }
    }

    Page {
        id: navBarItem
        implicitWidth: 78
        Rectangle {
            color: "yellow"
            anchors.fill: parent
            Label {
                text: "NavBar"
                anchors.centerIn: parent
            }
        }
    }

    Frame {
        id: wrapper
        width: layoutChooser.currentValue === "portrait" ? 400 : 800
        height: layoutChooser.currentValue === "portrait" ? 800 : 400
        anchors.centerIn: parent
        contentItem: StatusSectionLayout {
            id: sectionLayout
            clip: true
            leftPanel: leftPanelCheckBox.checked ? leftPanel : null
            centerPanel: centerPanelCheckBox.checked ? centerPanel : null
            rightPanel: rightPanel
            showRightPanel: rightPanelCheckBox.checked
            navBar: navBarItem
        }
    }
}