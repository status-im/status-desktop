import QtQuick
import QtQuick.Controls

import StatusQ.Core.Theme

import AppLayouts.Communities.controls

Page {
    id: root

    /* The right padding is not specified, the content item should provide proper
       padding on it's own. It allows to e.g. freely place the scroll bar within
       the padding area. */
    leftPadding: Theme.xlPadding * 2
    topPadding: Theme.padding

    property int headerLeftPadding: leftPadding
    property int headerRightPadding: leftPadding

    property int preferredHeaderContentWidth: availableWidth

    property alias buttons: pageHeader.buttons
    property alias subtitle: pageHeader.subtitle

    background: null

    header: SettingsPageHeader {
        id: pageHeader

        height: 44
        leftPadding: root.headerLeftPadding
        rightPadding: Math.max(root.headerRightPadding,
                               width - root.preferredHeaderContentWidth - root.headerRightPadding)

        title: root.title
    }
}
