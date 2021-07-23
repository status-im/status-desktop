import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"


Column {
    spacing: 0
    StatusSectionHeadline {
        text: qsTr("Bandwidth")
        topPadding: Style.current.bigPadding
        bottomPadding: Style.current.padding
    }

    Row {
        width: parent.width
        spacing: 10
        StyledText {
            text: "Upload"
            width: 250
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: 140
            height: 44
            Input {
                id: uploadRate
                text: Math.round(parseInt(nodeModel.uploadRate, 10) / 1024 * 100) / 100 
                width: parent.width
                readOnly: true
                customHeight: 44
                placeholderText: "0"
                anchors.top: parent.top
            }

            StyledText {
                color: Style.current.secondaryText
                text: qsTrId("Kb/s")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: uploadRate.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: 15
            }
        }

        StyledText {
            text: "Download"
            width: 273
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: 140
            height: 44
            Input {
                id: downloadRate
                text: Math.round(parseInt(nodeModel.downloadRate, 10) / 1024 * 100) / 100 
                width: parent.width
                readOnly: true
                customHeight: 44
                placeholderText: "0"
                anchors.top: parent.top
            }

            StyledText {
                color: Style.current.secondaryText
                text: qsTrId("Kb/s")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: downloadRate.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: 15
            }
        }
    }
}