import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls

ToolBar {
    id: root

    property string backButtonName: ""
    property Item headerContent
    property bool backButtonVisible: !!backButtonName

    signal backButtonClicked()

    objectName: "statusToolBar"
    leftPadding: 4
    rightPadding: 10
    topPadding: 8
    bottomPadding: 4
    background: null

    contentItem: RowLayout {
        spacing: 0
        StatusFlatButton {
            Layout.leftMargin: 20
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
            Layout.leftMargin: 8
            background: null
            contentItem: (!!headerContent) ? headerContent : null
        }
    }
}
