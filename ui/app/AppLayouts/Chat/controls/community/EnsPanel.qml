import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Controls.Validators 0.1

ColumnLayout {
    id: root

    enum EnsType {
        Any,
        CustomSubdomain
    }

    property int ensType: EnsPanel.EnsType.Any
    property alias domainName: domainNameInput.text
    property alias domainNameValid: domainNameInput.valid

    spacing: 0

    QtObject {
        id: d

        // values from design
        readonly property int pickerHeight: 36
        readonly property int pickerFontSize: 13
        readonly property int pickerLeftPadding: 12
        readonly property int pickerRightPadding: 9
    }

    // TODO (>=5.15): use inline components to reduce code duplication
    StatusListItem {
        title: qsTr("Any domain")

        Layout.fillWidth: true
        Layout.preferredHeight: d.pickerHeight

        leftPadding: d.pickerLeftPadding
        rightPadding: d.pickerRightPadding
        statusListItemTitle.font.pixelSize: d.pickerFontSize

        components: [
            StatusRadioButton {
                checked: root.ensType === EnsPanel.EnsType.Any
                size: StatusRadioButton.Size.Small
            }
        ]

        // using MouseArea instead of build-in 'clicked' signal to avoid
        // intercepting event by the StatusRadioButton
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.ensType = EnsPanel.EnsType.Any
        }
    }

    StatusListItem {
        title: qsTr("Custom subdomain")

        Layout.fillWidth: true
        Layout.preferredHeight: d.pickerHeight

        leftPadding: d.pickerLeftPadding
        rightPadding: d.pickerRightPadding
        statusListItemTitle.font.pixelSize: d.pickerFontSize

        components: [
            StatusRadioButton {
                checked: root.ensType === EnsPanel.EnsType.CustomSubdomain
                size: StatusRadioButton.Size.Small
            }
        ]

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.ensType = EnsPanel.EnsType.CustomSubdomain
        }
    }


    StatusInput {
        id: domainNameInput

        Layout.fillWidth: true
        Layout.topMargin: 8

        minimumHeight: 36
        maximumHeight: 36
        topPadding: 0
        bottomPadding: 0
        font.pixelSize: 13
        input.placeholderText: "name.eth"
        visible: root.ensType === EnsPanel.EnsType.CustomSubdomain

        validators: StatusRegularExpressionValidator {
            // TODO: check ens domain validator
            regularExpression: /^[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)?$/ig
            errorMessage: qsTr("Subdomain not recognized")
        }

        Component.onCompleted: {
            if (text) {
                input.dirty = true
                validate()
            }
        }
    }
}
