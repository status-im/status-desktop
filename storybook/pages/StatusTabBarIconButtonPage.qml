import QtQuick

import StatusQ.Controls

Item {

    Column {
        anchors.centerIn: parent
        spacing: 8

        Row {
            StatusTabBarIconButton {
                icon.name: "smileys-and-people"
                onClicked: highlighted = !highlighted
            }

            StatusTabBarIconButton {
                icon.name: "animals-and-nature"
                onClicked: highlighted = !highlighted
            }

            StatusTabBarIconButton {
                icon.name: "activity"
                onClicked: highlighted = !highlighted
            }

            StatusTabBarIconButton {
                icon.name: "travel-and-places"
                onClicked: highlighted = !highlighted
            }

            StatusTabBarIconButton {
                icon.name: "objects"
                onClicked: highlighted = !highlighted
            }

            StatusTabBarIconButton {
                icon.name: "symbols"
                onClicked: highlighted = !highlighted
            }

            StatusTabBarIconButton {
                icon.name: "flags"
                onClicked: highlighted = !highlighted
            }
        }
    }
}

// category: Controls
// status: good
