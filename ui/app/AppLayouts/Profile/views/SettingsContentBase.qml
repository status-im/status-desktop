import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property string sectionTitle
    property int contentWidth

    property string backButtonName: ""

    property alias titleRowComponentLoader: loader
    property list<Item> headerComponents
    default property Item content

    signal backButtonClicked()

    QtObject {
        id: d

        readonly property int topHeaderHeight: 56
        readonly property int titleRowHeight: 56
    }

    Component.onCompleted: {
        content.parent = contentWrapper

        if (headerComponents.length) {
            for (let i in headerComponents) {
                headerComponents[i].parent = titleRow
            }
        }
    }

    Item {
        id: topHeader
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: -Style.current.padding
        width: root.contentWidth + Style.current.padding
        height: d.topHeaderHeight

        StatusFlatButton {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Style.current.halfPadding
            visible: root.backButtonName != ""
            icon.name: "arrow-left"
            icon.width: 20
            icon.height: 20
            text: root.backButtonName
            size: StatusBaseButton.Size.Large
            onClicked: root.backButtonClicked()
        }
    }

    RowLayout {
        id: titleRow
        anchors.left: parent.left
        anchors.top: topHeader.bottom
        anchors.leftMargin: Style.current.padding
        width: root.contentWidth - 2 * Style.current.padding
        height: d.titleRowHeight
        visible: root.sectionTitle !== ""

        StatusBaseText {
            Layout.fillWidth: true
            text: root.sectionTitle
            font.weight: Font.Bold
            font.pixelSize: Constants.settingsSection.mainHeaderFontSize
            color: Theme.palette.directColor1
        }

        Loader {
            id: loader
        }
    }

    ScrollView {
        anchors.top: titleRow.visible? titleRow.bottom : topHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Style.current.bigPadding
        clip: true

        Column {
            id: contentWrapper
        }
    }
}
