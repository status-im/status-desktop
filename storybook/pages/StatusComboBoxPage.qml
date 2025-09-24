import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

Column {
    spacing: 20
    anchors.centerIn: parent

    ListModel {
        id: commmonModel
        ListElement {
            name: "Pascal"
        }
        ListElement {
            name: "Khushboo"
        }
        ListElement {
            name: "Alexandra"
        }
        ListElement {
            name: "Eric"
        }
    }

    StatusComboBox {
        id: combobox
        label: "ComboBox"
        model: commmonModel
    }

    StatusComboBox {
        id: comboBox1
        label: "ComboBox with custom delegate"
        model: commmonModel
        delegate: StatusItemDelegate {
            width: comboBox1.popup.width
            highlighted: comboBox1.control.highlightedIndex === index
            text: modelData
            font: comboBox1.control.font
            icon {
                name: "filled-account"
                color: Theme.palette.primaryColor1
            }
            enabled: index !== 2
        }
    }

    StatusComboBox {
        model: commmonModel
        label: "Disabled ComboBox"
        enabled: false
    }

    StatusComboBox {
        model: commmonModel
        label: "ComboBox with validation error"
        validationError: "Validation failed example"
    }

    StatusComboBox {
        model: commmonModel
        label: "Mirrored ComboBox"
        LayoutMirroring.enabled: true
    }
}

// category: Controls
