import QtQuick

import utils

// Component implementing the common ShowcaseDelegate interface needed for the ProfileShowcasePanel
// Workaround until the all plafroms support public inline components.
// Linux and windows needs to be upgraded to qt 5.15.8+
// https://bugreports.qt.io/browse/QTBUG-89180

// TODO: Revert this commit once the inline componets are supported
// Remove this file and use the inline component once all platforms are upgraded to 5.15.8+
ShowcaseDelegate {
    id: root
    
    // required property modelData
    // required property dragKeysData
    // required property dragParentData
    // required property visualIndexData

    readonly property var model: modelData
    readonly property var key: model ? model.showcaseKey : null

    Drag.keys: dragKeysData

    dragParent: dragParentData
    visualIndex: visualIndexData
    dragAxis: Drag.YAxis
    showcaseVisibility: model ? model.showcaseVisibility ?? Constants.ShowcaseVisibility.NoOne :
                                    Constants.ShowcaseVisibility.NoOne
}
