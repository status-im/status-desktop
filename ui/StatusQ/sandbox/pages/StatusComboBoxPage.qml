import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import Sandbox 0.1

Column {
    spacing: 20

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
            width: comboBox1.control.width
            highlighted: comboBox1.control.highlightedIndex === index
            text: modelData
            font: comboBox1.control.font
            icon {
                name: "filled-account"
                color: Theme.palette.primaryColor1
            }
            enabled: index != 2
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

