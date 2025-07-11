import QtQuick
import QtQuick.Controls

import StatusQ.Core.Theme

import AppLayouts.Communities.controls

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
