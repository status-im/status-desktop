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
        width: parent.width

        RowLayout {
            Text {
                text: "Buttons"
            }
        }

        /* Commented due to high cpu usage */
        /*
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
                size: "small"
            }

            StatusRoundButton {
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
            }

            StatusRoundButton {
                size: "medium"
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
            }

            StatusRoundButton {
                size: "small"
                icon.name: "arrow-right"
                icon.height: 12
                icon.width: 18
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
                size: "medium"
                icon.name: "arrow-right"
                icon.height: 15
                icon.width: 20
                enabled: false
            }

            StatusRoundButton {
                size: "small"
                icon.name: "arrow-right"
                icon.height: 12
                icon.width: 18
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
                size: "medium"
                state: "pending"
            }

            StatusRoundButton {
                size: "small"
                state: "pending"
            }
        }

        RowLayout {
            width: parent.width
            Layout.fillWidth: true
            Item {
                width: parent.width
                height: addressComponent.height
                Layout.fillWidth: true
                Address {
                    id: addressComponent
                    text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
                    width: 100
                }
            }
        }
        RowLayout {
            width: parent.width
            Layout.fillWidth: true
            Item {
                width: parent.width
                height: addressComponent.height
                Layout.fillWidth: true
                Address {
                    id: addressComponentWidthAnchors
                    text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width - 100
                }
            }
        }
        */
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.75;height:480;width:1000}
}
##^##*/
