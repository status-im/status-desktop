import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Grid {

    columns: 3
    columnSpacing: 38
    rowSpacing: 10

    horizontalItemAlignment: Grid.AlignHCenter

    // Large
    StatusButton {
        text: "Button"
    }

    StatusButton {
        text: "Button"
        enabled: false
    }

    StatusButton {
        text: "Button"
        loading: true
    }

    StatusButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
    }

    StatusButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
        enabled: false
    }

    StatusButton {
        text: "Button"
        loading: true
        type: StatusBaseButton.Type.Danger
    }

    StatusFlatButton {
        text: "Button"
    }

    StatusFlatButton {
        text: "Button"
        enabled: false

    }

    StatusFlatButton {
        text: "Button"
        loading: true
    }

    StatusFlatButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
    }

    StatusFlatButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
        enabled: false
    }

    StatusFlatButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
        loading: true
    }

    // Small
    StatusButton {
        text: "Button"
        size: StatusBaseButton.Size.Small
    }

    StatusButton {
        text: "Button"
        enabled: false
        size: StatusBaseButton.Size.Small
    }

    StatusButton {
        text: "Button"
        size: StatusBaseButton.Size.Small
        loading: true
    }

    StatusButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
        size: StatusBaseButton.Size.Small
    }

    StatusButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
        size: StatusBaseButton.Size.Small
        enabled: false
    }

    StatusButton {
        text: "Button"
        type: StatusBaseButton.Type.Danger
        size: StatusBaseButton.Size.Small
        loading: true
    }

    StatusFlatButton {
        text: "Button"
        size: StatusBaseButton.Size.Small
    }

    StatusFlatButton {
        text: "Button"
        enabled: false
        size: StatusBaseButton.Size.Small
    }

    StatusFlatButton {
        text: "Button"
        enabled: false
        size: StatusBaseButton.Size.Small
        loading: true
    }

    // Icon buttons

    // blue

    StatusRoundButton {
        icon: "info"
    }

    StatusRoundButton {
        icon: "info"
        enabled: false
    }

    StatusRoundButton {
        icon: "info"
        loading: true
    }

    // black

    StatusRoundButton {
        type: StatusRoundButton.Type.Secondary
        icon: "info"
    }

    StatusRoundButton {
        type: StatusRoundButton.Type.Secondary
        icon: "info"
        enabled: false
    }

    StatusRoundButton {
        type: StatusRoundButton.Type.Secondary
        icon: "info"
        loading: true
    }

    // Rounded blue

    StatusFlatRoundButton {
        width: 44
        height: 44

        icon: "info"
    }

    StatusFlatRoundButton {
        width: 44
        height: 44
        icon: "info"
        enabled: false
    }

    StatusFlatRoundButton {
        width: 44
        height: 44
        icon: "info"
        loading: true
    }

    // Rounded white

    StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 44
        height: 44

        icon: "info"
    }

    StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 44
        height: 44
        icon: "info"
        enabled: false
    }

    StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 44
        height: 44
        icon: "info"
        loading: true
    }

    StatusFlatButton {
        iconName: "info"
        text: "Button"
        size: StatusBaseButton.Size.Small
    }
    StatusFlatButton {
        iconName: "info"
        text: "Button"
        enabled: false
        size: StatusBaseButton.Size.Small
    }

    StatusFlatButton {
        iconName: "info"
        text: "Button"
        loading: true
        size: StatusBaseButton.Size.Small
    }
}
