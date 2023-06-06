import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Chat.views.communities 1.0

Item {
    id: root

    property var holdingsModel
    property var assetsModel
    property var collectiblesModel

    QtObject {
        id: d
        property int panelRowSpacing: 4 // by design
    }

    RowLayout {
        anchors.fill: parent
        spacing: d.panelRowSpacing
        StatusBaseText {
            text: qsTr("To post, hold")
            font.pixelSize: Style.current.primaryTextFontSize
            color: Style.current.secondaryText
        }

        StatusScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            contentWidth: tokenRow.implicitWidth
            padding: 0
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            Row {
                id: tokenRow
                Repeater {
                    id: repeater
                    model: root.holdingsModel
                    Row {
                        spacing: d.panelRowSpacing
                        Row {
                            spacing: d.panelRowSpacing
                            Repeater {
                                model: HoldingsSelectionModel {
                                    sourceModel: holdingsListModel
                                    assetsModel: root.assetsModel
                                    collectiblesModel: root.collectiblesModel
                                }
                                StatusListItemTag {
                                    height: 20
                                    enabled: false
                                    leftPadding: 2
                                    title: model.text
                                    asset.name: model.imageSource
                                    asset.isImage: true
                                    asset.bgColor: "transparent"
                                    asset.height: 16
                                    asset.width: asset.height
                                    asset.bgWidth: asset.height
                                    asset.bgHeight: asset.height
                                    asset.color: asset.isImage ? "transparent" : titleText.color
                                    closeButtonVisible: false
                                    titleText.color: model.available ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
                                    bgColor: model.available ? Theme.palette.primaryColor2 :Theme.palette.dangerColor2
                                    titleText.font.pixelSize: 12
                                }
                            }
                        }
                        StatusBaseText {
                            height: parent.height
                            visible: (index !== (repeater.count - 1))
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Style.current.primaryTextFontSize
                            rightPadding: d.panelRowSpacing
                            color: Style.current.secondaryText
                            text: qsTr("or")
                        }
                    }
                }
            }
        }
        Item { Layout.fillWidth: true }
    }
}
