import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

ColumnLayout {
    id: root

    property string name: "Uniswap"
    property int membersCount: 184
    property bool amISectionAdmin: false
    property color color: "orchid"
    property url image: Style.png("tokens/UNI")
    property bool colorVisible: false

    spacing: 24

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Name"
        }
        TextField {
            background: Rectangle { border.color: 'lightgrey' }
            Layout.preferredWidth: 200
            text: root.name
            onTextChanged: root.name = text
        }
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Community members:"
        }

        Slider {
            value: root.membersCount
            from: 0
            to: 1000
            onValueChanged: root.membersCount = value
        }
    }

    ColumnLayout {
        visible: root.colorVisible
        Label {
            Layout.fillWidth: true
            text: "Community color:"
        }

        RadioButton {
            checked: true
            text: "Orchid"
            onCheckedChanged: if(checked) root.color = "orchid"
        }
        RadioButton {
            text: "Blue"
            onCheckedChanged: if(checked) root.color = "blue"
        }
        RadioButton {
            text: "Orange"
            onCheckedChanged: if(checked) root.color = "orange"
        }
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Community image:"
        }

        RadioButton {
            checked: true
            text: qsTr("UNI")
            onCheckedChanged: if(checked) root.image = Style.png("tokens/UNI")
        }
        RadioButton {
            text: qsTr("SOCKS")
            onCheckedChanged: if(checked) root.image = Style.png("tokens/SOCKS")
        }
        RadioButton {
            text: qsTr("Status")
            onCheckedChanged: if(checked) root.image = Style.png("tokens/SNT")
        }
    }

    RowLayout {
        Label {
            text: "Is community admin:"
        }

        CheckBox {
            checked: root.amISectionAdmin
            onCheckedChanged: root.amISectionAdmin = checked
        }
    }
}
