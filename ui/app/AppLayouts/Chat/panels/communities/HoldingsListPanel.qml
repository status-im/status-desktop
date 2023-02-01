import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Chat.helpers 1.0
import AppLayouts.Chat.controls.community 1.0

import SortFilterProxyModel 0.2

import utils 1.0

Control {
    id: root

    property var model
    property string introText

    QtObject {
        id: d

        // By design values:
        readonly property int defaultHoldingsSpacing: 8

        function holdingsTextFormat(name, amount) {
            return CommunityPermissionsHelpers.setHoldingsTextFormat(HoldingTypes.Type.Asset, name, amount)
        }
    }

    contentItem: ColumnLayout {
        spacing: root.spacing

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: root.introText
            textFormat: Text.StyledText
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: d.defaultHoldingsSpacing

            Repeater {
                model: root.model

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: d.defaultHoldingsSpacing

                    RowLayout {
                        spacing: 18 // by design

                        Repeater {
                            model: SortFilterProxyModel {
                                sourceModel: holdingsListModel
                                proxyRoles: ExpressionRole {
                                    name: "text"
                                    // Direct call for singleton function is not handled properly by SortFilterProxyModel that's why `holdingsTextFormat` is used instead.
                                    expression: d.holdingsTextFormat(model.name, model.amount)
                                }
                            }

                            StatusListItemTag {
                                enabled: false
                                leftPadding: 2
                                title: text
                                asset.name: model.imageSource
                                asset.isImage: true
                                asset.bgColor: "transparent"
                                asset.height: 28
                                asset.width: asset.height
                                closeButtonVisible: false
                                titleText.color: model.available ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
                                bgColor: model.available ? Theme.palette.primaryColor2 :Theme.palette.dangerColor2
                                titleText.font.pixelSize: 15
                            }
                        }
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("or")
                        textFormat: Text.StyledText
                        visible: (index !== root.model.count - 1)
                    }
                }
            }
        }
    }
}
