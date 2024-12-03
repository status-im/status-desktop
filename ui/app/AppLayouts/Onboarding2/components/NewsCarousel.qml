import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root

    // [{primary:string, secondary:string, image:string}]
    required property var newsModel

    background: Rectangle {
        color: StatusColors.colors["neutral-95"]
        radius: 20
    }

    contentItem: Item {
        id: newsPage
        readonly property string primaryText: root.newsModel.get(pageIndicator.currentIndex).primary
        readonly property string secondaryText: root.newsModel.get(pageIndicator.currentIndex).secondary

        Image {
            readonly property int size: Math.min(parent.width / 3 * 2, parent.height / 2, 370)
            anchors.centerIn: parent
            width: size
            height: size
            source: Theme.png(root.newsModel.get(pageIndicator.currentIndex).image)
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48 - root.padding
            width: Math.min(300, parent.width)
            spacing: 4

            StatusBaseText {
                Layout.fillWidth: true
                text: newsPage.primaryText
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.DemiBold
                color: Theme.palette.white
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: newsPage.secondaryText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.additionalTextSize
                color: Theme.palette.white
                wrapMode: Text.WordWrap
            }

            PageIndicator {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.halfPadding
                id: pageIndicator
                interactive: true
                count: root.newsModel.count
                currentIndex: -1
                Component.onCompleted: currentIndex = 0 // start switching pages

                function switchToNextOrFirstPage() {
                    currentIndex = (currentIndex + 1) % count
                }

                delegate: Control {
                    id: pageIndicatorDelegate
                    implicitWidth: 44
                    implicitHeight: 8

                    readonly property bool isCurrentPage: index === pageIndicator.currentIndex

                    background: Rectangle {
                        color: Qt.rgba(1, 1, 1, 0.1)
                        radius: 4
                        HoverHandler {
                            cursorShape: hovered ? Qt.PointingHandCursor : undefined
                        }
                    }
                    contentItem: Item {
                        Rectangle {
                            NumberAnimation on width {
                                from: 0
                                to: pageIndicatorDelegate.availableWidth
                                duration: 3000
                                running: pageIndicatorDelegate.isCurrentPage
                                onStopped: {
                                    if (pageIndicatorDelegate.isCurrentPage)
                                        pageIndicator.switchToNextOrFirstPage()
                                }
                            }

                            height: parent.height
                            color: pageIndicatorDelegate.isCurrentPage ? Theme.palette.white : "transparent"
                            radius: 4
                        }
                    }
                }
            }
        }
    }
}
