import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme
import QtQuick.Window


Control {
    id: root

    property alias showTracer: showTracer.checked
    property alias cardWidth: cardWidth.value

    property int minCardWidth: 256
    property int maxCardWidth: 400

    background: Rectangle {
        color: Theme.palette.directColor8
        radius: 8
    }

    contentItem: ColumnLayout {
        spacing: Theme.halfPadding


        Label {
            Layout.topMargin: Theme.padding
            Layout.leftMargin: Theme.padding
            Layout.bottomMargin: Theme.padding
            text: "LAYOUT AND TEXT SIZES"
            font.weight: Font.Bold
        }

        CheckBox {
            id: showTracer
            Layout.leftMargin: Theme.padding
            text: "Show Tracer?"
            checked: true
        }

        Label {
            text: "Text Size"
            Layout.leftMargin: Theme.padding
            font.weight: Font.Bold
        }

        RadioButton {
            Layout.leftMargin: Theme.padding
            text: "XS"
            onCheckedChanged: {
                ThemeUtils.setFontSize(Window.window, ThemeUtils.FontSize.FontSizeXS)
            }
        }

        RadioButton {
            Layout.leftMargin: Theme.padding
            text: "S"
            onCheckedChanged: {
                ThemeUtils.setFontSize(Window.window, ThemeUtils.FontSize.FontSizeS)
            }
        }

        RadioButton {
            Layout.leftMargin: Theme.padding
            text: "M"
            checked: true
            onCheckedChanged: {
                ThemeUtils.setFontSize(Window.window, ThemeUtils.FontSize.FontSizeM)
            }
        }

        RadioButton {
            Layout.leftMargin: Theme.padding
            text: "L"
            onCheckedChanged: {
                ThemeUtils.setFontSize(Window.window, ThemeUtils.FontSize.FontSizeL)
            }
        }

        RadioButton {
            Layout.leftMargin: Theme.padding
            text: "XL"
            onCheckedChanged: {
                ThemeUtils.setFontSize(Window.window, ThemeUtils.FontSize.FontSizeXL)
            }
        }

        RadioButton {
            Layout.leftMargin: Theme.padding
            text: "XXL"
            onCheckedChanged: {
                ThemeUtils.setFontSize(Window.window, ThemeUtils.FontSize.FontSizeXXL)
            }
        }

        Label {
            text: "Card width"
            Layout.leftMargin: Theme.padding
            font.weight: Font.Bold
        }

        Slider {
            id: cardWidth
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            Layout.fillWidth: true
            value: from
            from: root.minCardWidth
            to: root.maxCardWidth
        }
    }
}

