import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

import StatusQ.Core.Theme
import Storybook

ApplicationWindow {
    width: 1450
    height: 840
    visible: true

    title: "%1 – %2".arg(storybook.currentPage).arg(Qt.application.displayName)
    font.pixelSize: Theme.additionalTextSize

    // cf. Universal theme kept here as the basic light/dark theme for the app itself
    Universal.theme: storybook.darkMode ? Universal.Dark : Universal.Light

    Storybook {
        id: storybook

        anchors.fill: parent

        onDarkModeChanged: Theme.changeTheme(darkMode ? Theme.Style.Dark
                                                      : Theme.Style.Light)
    }
}
