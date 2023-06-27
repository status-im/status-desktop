import QtQuick 2.15

import StatusQ.Core 0.1

import AppLayouts.Communities.panels 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design

    property alias image: introPanel.image
    property alias title: introPanel.title
    property alias subtitle: introPanel.subtitle
    property alias checkersModel: introPanel.checkersModel

    padding: 0

    IntroPanel {
        id: introPanel

        width: root.viewWidth
    }
}
