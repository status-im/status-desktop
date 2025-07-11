import QtQuick
import QtQuick.Layouts
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

ColumnLayout {
    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        columns: 6
        columnSpacing: 5
        rowSpacing: 5

        StatusLoadingIndicator {
            color: Theme.palette.directColor4
        }

        StatusLetterIdenticon {
            name: "#status"
        }

        StatusRoundedImage {
            image.source: "qrc:/demoapp/data/profile-image-1.jpeg"
        }

        StatusBadge {}

        StatusBadge {
            value: 1
        }

        StatusBadge {
            value: 10
        }

        StatusBadge {
            value: 100
        }

        StatusRoundIcon {
            asset.name: "info"
        }
    }

    Flow {
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: 12
            StatusLetterIdenticon {
                name: "A"
                letterIdenticonColor: Theme.palette.userCustomizationColors[index]
                letterSize: 16
            }
        }
    }

    StatusDatePicker {
        label: "Select date"
    }
}
