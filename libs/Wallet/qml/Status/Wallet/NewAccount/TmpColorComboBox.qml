import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ComboBox {
    id: colorCombo

    model: ListModel {
        ListElement { colorText: "Red"; colorValue: "red" }
        ListElement { colorText: "Green"; colorValue: "green" }
        ListElement { colorText: "Blue"; colorValue: "blue" }
        ListElement { colorText: "Orange"; colorValue: "orange" }
        ListElement { colorText: "Pink"; colorValue: "pink" }
        ListElement { colorText: "Fuchsia"; colorValue: "fuchsia" }
    }
    textRole: "colorText"
    valueRole: "colorValue"

    currentIndex: 0

    delegate: ItemDelegate {
            required property string colorText
            required property color colorValue
            required property int index

            width: colorCombo.width
            contentItem: Text {
                text: colorText
                color: colorValue
                font: colorCombo.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: colorCombo.highlightedIndex === index
    }
}
