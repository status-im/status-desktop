import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

Page {
    signal openLink(string link)
    signal openLinkWithConfirmation(string link, string domain)

    implicitWidth: 1200
    implicitHeight: 700

    padding: 12

    background: Rectangle {
        color: Theme.palette.background
    }
}
