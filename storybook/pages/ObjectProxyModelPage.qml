import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {

    TabBar {
        id: tabBar

        TabButton {
            text: "Example 1"
        }

        TabButton {
            text: "Example 2"
        }
    }

    StackLayout {
        id: stackLayout

        Layout.fillWidth: true
        Layout.fillHeight: true

        currentIndex: tabBar.currentIndex

        ObjectProxyModelExample1 {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        ObjectProxyModelExample2 {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}

// category: Models
