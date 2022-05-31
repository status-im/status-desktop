import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Status.Application.Navigation
import Status.Controls.Navigation

NavigationBarSection {
    id: root

    implicitHeight: walletButton.implicitHeight

    StatusNavigationButton {
        id: walletButton

        anchors.fill: parent

        // TODO: icon, tooltip ...
    }
}
