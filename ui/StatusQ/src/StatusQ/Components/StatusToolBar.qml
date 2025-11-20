import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

ToolBar {
    id: root

    property string backButtonName: ""
    property Item headerContent
    property bool backButtonVisible: !!backButtonName

    signal backButtonClicked()

    objectName: "statusToolBar"
    leftPadding: Theme.halfPadding/2
    rightPadding: Theme.smallPadding
    topPadding: Theme.halfPadding
    bottomPadding: Theme.halfPadding/2
    background: null

    contentItem: RowLayout {
        spacing: 0
        StatusFlatButton {
            Layout.leftMargin: Theme.smallPadding*2
            objectName: "toolBarBackButton"
            icon.name: "arrow-left"
            visible: root.backButtonVisible
            text: root.backButtonName
            onClicked: { root.backButtonClicked(); }
        }

        Control {
            id: headerContentItem
            Layout.fillWidth: !!headerContent
            Layout.fillHeight: !!headerContent
            Layout.leftMargin: Theme.halfPadding
            background: null
            contentItem: (!!headerContent) ? headerContent : null
        }
    }
}
