import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import StatusQ.Core

import utils

StatusListView {
    id: root

    property string placeholderText
    property int footerHeight: 44
    property bool footerContentVisible: true
    property Component additionalFooterComponent

    ScrollBar.vertical: null
    footerPositioning: ListView.PullBackFooter


    footer: ColumnLayout {
        width: root.width

        Item {
            Layout.preferredHeight: root.footerHeight
            Layout.fillWidth: true

            visible: root.model && root.count === 0

            ShapeRectangle {
                id: shapeRectangle

                anchors.fill: parent
                anchors.margins: 1

                visible: root.footerContentVisible
                text: root.placeholderText
            }
        }

        Loader {
            Layout.preferredWidth: root.width

            sourceComponent: root.additionalFooterComponent
        }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
    }
}
