import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.TradingCenter 1.0

SplitView {
    orientation: Qt.Vertical

    TradingCenterLayout {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
    }
}

// category: Views

// https://www.figma.com/design/mh7hMVynZjL3eiV7e5oEyk/Trading?node-id=243-163195&m=dev
