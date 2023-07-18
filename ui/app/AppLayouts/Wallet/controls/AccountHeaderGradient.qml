import QtQuick 2.13
import QtGraphicalEffects 1.12

import StatusQ.Core.Theme 0.1

import utils 1.0

Loader {
    id: root

    property var overview

    sourceComponent: root.overview && root.overview.isAllAccounts ? multipleAccountsGradient : singleAccountGradient

    Component {
        id: singleAccountGradient
        Rectangle {
            implicitHeight: 115
            gradient: Gradient {
                GradientStop { position: 0.0; color: overview && overview.colorId ? Theme.palette.alphaColor(Utils.getColorForId(overview.colorId), 0.1) : "" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }
    Component {
        id: multipleAccountsGradient
        Item {
            implicitHeight: 115
            Rectangle {
                id: base
                anchors.fill: parent
                Component.onCompleted: {
                    let splitWords = root.overview.colorIds.split(';')

                    var stops = []
                    let numOfColors = splitWords.length
                    let gap =  1/splitWords.length
                    let startPosition = gap
                    for (const word of splitWords) {
                        stops.push(stopComponent.createObject(base, {"position":startPosition, "color": Theme.palette.alphaColor(Utils.getColorForId(word), 0.1)}))
                        startPosition += gap
                    }
                    gradient.stops = stops
                }

                gradient: Gradient {
                    id: gradient
                    orientation: Gradient.Horizontal
                }
                visible: false
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color:  Theme.palette.statusAppLayout.rightPanelBackgroundColor}
                    GradientStop { position: 1.0; color: "transparent" }
                }
                visible: false
            }

            OpacityMask {
                anchors.fill: base
                source: base
                maskSource: mask
            }
        }
    }
    Component {
        id:stopComponent
        GradientStop {}
    }
}
