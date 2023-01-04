import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Monitoring 1.0


Component {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 15

        Label {
            Layout.fillWidth: true

            text: "Context properties:"
            font.bold: true
        }

        ListView {
            id: lv

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true


            model: Monitor.contexPropertiesNames

            spacing: 5

            delegate: Text {
                text: modelData
            }
        }
    }
}
