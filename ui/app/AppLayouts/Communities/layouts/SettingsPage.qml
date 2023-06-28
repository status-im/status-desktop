import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.controls 1.0

Page {
    id: root

    leftPadding: 64
    topPadding: 16

    property alias buttons: pageHeader.buttons
    property alias pageTitle: pageHeader.title
    property alias pageSubtitle: pageHeader.subtitle

    background: null

    header: SettingsPageHeader {
        id: pageHeader

        height: 44
        leftPadding: 64
        rightPadding: width - 560 - leftPadding
    }
}
