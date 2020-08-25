import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"


Item {
    id: uiComponentCatalog
    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout {
        id: buttons
        spacing: 6

        RowLayout {
            Text {
                text: "Buttons"
            }
        }

        RowLayout {
            StatusButton {
                text: "Primary Large Button"
            }

            StatusButton {
                text: "Secondary Large Button"
                type: "secondary"
            }

            StatusButton {
                text: "Primary Small Button"
                size: "small"
            }

            StatusButton {
                text: "Secondary Small Button"
                type: "secondary"
                size: "small"
            }

            StatusRoundButton {
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
            }

            StatusRoundButton {
                type: "secondary"
                size: "medium"
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
            }
        }

        RowLayout {
            StatusButton {
                text: "Primary Large Button"
                enabled: false
            }

            StatusButton {
                text: "Secondary Large Button"
                type: "secondary"
                enabled: false
            }

            StatusButton {
                text: "Primary Small Button"
                enabled: false
                size: "small"
            }

            StatusButton {
                text: "Secondary Small Button"
                type: "secondary"
                enabled: false
                size: "small"
            }

            StatusRoundButton {
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
                enabled: false
            }

            StatusRoundButton {
                type: "secondary"
                size: "medium"
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
                enabled: false
            }
        }

        RowLayout {
            StatusButton {
                text: "Primary Large Button"
                state: "pending"
            }

            StatusButton {
                text: "Secondary Large Button"
                type: "secondary"
                state: "pending"
            }

            StatusButton {
                text: "Primary Large Button"
                state: "pending"
                size: "small"
            }

            StatusButton {
                text: "Secondary Large Button"
                type: "secondary"
                state: "pending"
                size: "small"
            }

            StatusRoundButton {
                state: "pending"
            }

            StatusRoundButton {
                type: "secondary"
                size: "medium"
                state: "pending"
            }
        }
    }
}
