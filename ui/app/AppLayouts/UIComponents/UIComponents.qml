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
            StButton {
                text: "Primary Large Button"
            }

            StButton {
                text: "Secondary Large Button"
                type: "secondary"
            }

            StButton {
                text: "Primary Small Button"
                size: "small"
            }

            StButton {
                text: "Secondary Small Button"
                type: "secondary"
                size: "small"
            }

            StRoundButton {
                text: "\u2713"    
            }
        }

        RowLayout {
            StButton {
                text: "Primary Large Button"
                enabled: false
            }

            StButton {
                text: "Secondary Large Button"
                type: "secondary"
                enabled: false
            }

            StButton {
                text: "Primary Small Button"
                enabled: false
                size: "small"
            }

            StButton {
                text: "Secondary Small Button"
                type: "secondary"
                enabled: false
                size: "small"
            }

            StRoundButton {
                
            }
        }

        RowLayout {
            StButton {
                text: "Primary Large Button"
                state: "pending"
            }

            StButton {
                text: "Secondary Large Button"
                type: "secondary"
                state: "pending"
            }

            StButton {
                text: "Primary Large Button"
                state: "pending"
                size: "small"
            }

            StButton {
                text: "Secondary Large Button"
                type: "secondary"
                state: "pending"
                size: "small"
            }

            StRoundButton {
                
            }
        }
    }
}
