import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1

import utils 1.0

StatusListView {
    id: root

    property string placeholderText
    property int placeholderHeight: 44
    property Component additionalFooterComponent

    // TO BE REMOVE: #13498
    property bool empty: root.model && root.count === 0

    ScrollBar.vertical: null

    footer: ColumnLayout {
        width: root.width

        ShapeRectangle {
            id: shapeRectangle

            Layout.preferredHeight: root.placeholderHeight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 1

            visible: root.empty// TO BE REPLACE by (#13498):  root.model && root.count === 0
            text: root.placeholderText
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
