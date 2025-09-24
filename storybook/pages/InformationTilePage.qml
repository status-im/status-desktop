import QtQuick
import QtQuick.Layouts

import shared.controls

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent

        InformationTile {
            primaryText: "Some text text text text text sdf"
            secondaryText: "Unconstrained some secondary text"
        }

        InformationTile {
            Layout.preferredWidth: 150

            primaryText: "Some text text text text text sdf"
            secondaryText: "Constrained some secondary text"
        }
    }
}

// category: Controls
// status: good
