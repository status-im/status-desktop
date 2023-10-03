import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.controls 1.0

SplitView {
    id: root

    property var assetsModel: AssetsModel {}
    property var collectiblesModel: CollectiblesModel {}

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: "1 permission:"
            }

            PermissionsRow {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.bottomMargin: spacing

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: PermissionsModel.shortPermissionsModel
                requirementsMet: permissionsMetCheckEditor.checked
            }

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: "2 short permissions:"
            }

            PermissionsRow {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.bottomMargin: spacing

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: PermissionsModel.twoShortPermissionsModel
                requirementsMet: permissionsMetCheckEditor.checked
            }

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: "2 long permissions:"
            }

            PermissionsRow {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.bottomMargin: spacing

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: PermissionsModel.twoLongPermissionsModel
                requirementsMet: permissionsMetCheckEditor.checked
            }

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: "Three short permissions:"
            }

            PermissionsRow {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.bottomMargin: spacing

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: PermissionsModel.threeShortPermissionsModel
                requirementsMet: permissionsMetCheckEditor.checked
            }

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: "More than 2 permissions with short 1st and 2nd ones:"
            }

            PermissionsRow {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.bottomMargin: spacing

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: PermissionsModel.moreThanTwoInitialShortPermissionsModel
                requirementsMet: permissionsMetCheckEditor.checked
            }

            Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: "5 permissions - long ones"
            }

            PermissionsRow {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.preferredHeight: heighSliderEditor.value
                Layout.bottomMargin: spacing

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                model: PermissionsModel.longPermissionsModel
                requirementsMet: permissionsMetCheckEditor.checked

                spacing: spacingSliderEditor.value
                padding: paddingSliderEditor.value
                fontPixelSize: 13
                overlapping: overlappingSliderEditor.value
                overlappingBorder: overlappingBorderSliderEditor.value
                backgroundRadius: 10
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            CheckBox {
                id: permissionsMetCheckEditor

                text: "Are permissions met?"
            }

            Label {
                text: "Row heigh:"
            }

            Slider {
                id: heighSliderEditor

                value: 32
                from: 24
                to: 64
            }

            Label {
                text: "Overlapping:"
            }

            Slider {
                id: overlappingSliderEditor

                value: 8
                from: 0
                to: 16
            }

            Label {
                text: "Overlapping border:"
            }

            Slider {
                id: overlappingBorderSliderEditor

                value: 2
                from: 0
                to: 8
            }

            Label {
                text: "Spacing:"
            }

            Slider {
                id: spacingSliderEditor

                value: 4
                from: 0
                to: 16
            }

            Label {
                text: "Padding:"
            }

            Slider {
                id: paddingSliderEditor

                value: 2
                from: 0
                to: 8
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=28570-546277&t=PVEC7ehRew4RnGFa-0
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=8159%3A416159&t=bTEq7jsSZT0nfC4y-1
// https://www.figma.com/file/WQZcp6S0EnzxdTL4taoKDv/Design-System-for-Mobile?node-id=17582-215241&t=8cRmw5jIlzUtfJbY-0
