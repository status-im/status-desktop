import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

import AppLayouts.Communities.panels
import AppLayouts.Communities.helpers

Control {
    id: root

    required property string communityLogo
    required property string communityColor
    required property string communityName

    property bool isOwner
    property bool showTag

    property alias checkersModel: checkersItems.model

    QtObject {
        id: d

        readonly property int margins: Theme.bigPadding
    }

    background: Rectangle {
        color: Theme.palette.transparent
        radius: Theme.radius
        border.color: Theme.palette.baseColor2
    }

    contentItem: RowLayout {
        spacing: d.margins

        PrivilegedTokenArtworkPanel {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: d.margins
            Layout.leftMargin: Layout.topMargin

            isOwner: root.isOwner
            artwork: root.communityLogo
            color: root.communityColor
            showTag: root.showTag
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: d.margins
            Layout.bottomMargin: d.margins
            Layout.fillWidth: true

            Item {
                id: panelTextHeader

                Layout.fillWidth: true
                Layout.preferredHeight: headerRow.implicitHeight
                Layout.rightMargin: d.margins

                RowLayout {
                    id: headerRow

                    spacing: Theme.halfPadding

                    StatusBaseText {
                        Layout.alignment: Qt.AlignBottom
                        Layout.maximumWidth: panelTextHeader.width - symbol.width

                        text: root.isOwner ? qsTr("%1 Owner token").arg(root.communityName) :
                                             qsTr("%1 TokenMaster token").arg(root.communityName)
                        font.bold: true
                        font.pixelSize: Theme.secondaryAdditionalTextSize
                        elide: Text.ElideMiddle
                    }

                    StatusBaseText {
                        id: symbol

                        Layout.alignment: Qt.AlignBottom

                        text: PermissionsHelpers.communityNameToSymbol(root.isOwner, root.communityName)
                        font.pixelSize: Theme.primaryTextFontSize
                        color: Theme.palette.baseColor1
                    }
                }
            }

            ColumnLayout {
                id: checkersColumn

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 6

                Repeater {
                    id: checkersItems

                    objectName: "Checklist"

                    RowLayout {
                        StatusIcon {
                            icon: "tiny/checkmark"
                            color: Theme.palette.successColor1
                            width: 20
                            height: width
                        }

                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.rightMargin: d.margins

                            text: modelData
                            lineHeight: 1.2
                            font.pixelSize: Theme.additionalTextSize
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
