import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import Sandbox 0.1

Column {
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
