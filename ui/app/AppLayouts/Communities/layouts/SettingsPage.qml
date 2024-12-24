import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.controls 1.0

Page {
    id: root

    leftPadding: Theme.xlPadding*2
    topPadding: Theme.padding

    readonly property int preferredContentWidth: 560

    property alias buttons: pageHeader.buttons
    property alias subtitle: pageHeader.subtitle

    background: null

    header: SettingsPageHeader {
        id: pageHeader

        height: 44
        leftPadding: root.leftPadding
        rightPadding: width - root.preferredContentWidth - leftPadding

        title: root.title
    }
}
