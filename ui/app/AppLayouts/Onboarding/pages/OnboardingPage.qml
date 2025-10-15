import QtQuick
import QtQuick.Controls

import StatusQ.Core.Theme

Page {
    signal requestOpenLink(string link)

    implicitWidth: 1200
    implicitHeight: 700

    padding: 12

    background: Rectangle {
        color: Theme.palette.background
    }
}
