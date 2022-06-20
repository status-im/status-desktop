import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../"
import "../../stores"
import "../../controls"

StackDetailBase {
    id: root
    backButtonText: "Collectibles"

    property var assetStats: RootStore.collectiblesStore.stats
    property var assetRankings: RootStore.collectiblesStore.rankings
    property var assetProperties: RootStore.collectiblesStore.properties
    property int collectionIndex: RootStore.collectiblesStore.collectionIndex

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.left: parent.left
        anchors.right: parent.right
        image.source: RootStore.collectiblesStore.collectibleImageUrl
        primaryText: RootStore.collectiblesStore.name
        secondaryText: RootStore.collectiblesStore.collectibleId
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: collectibleHeader.bottom
        anchors.topMargin: Style.dp(46)

        Row {
            id: collectibleImageDetails
            anchors.top: parent.top
            width: parent.width
            spacing: Style.dp(24)

            StatusRoundedImage {
                id: collectibleimage
                width: Style.dp(253)
                height: Style.dp(253)
                radius: Style.dp(2)
                color: RootStore.collectiblesStore.backgroundColor
                border.color: Theme.palette.directColor8
                border.width: Style.dp(1)
                image.source: RootStore.collectiblesStore.imageUrl
            }
            StatusBaseText {
                id: collectibleText
                width: parent.width - collectibleimage.width - Style.dp(24)
                height: collectibleimage.height

                text: RootStore.collectiblesStore.description
                color: Theme.palette.directColor1
                font.pixelSize: Style.current.primaryTextFontSize
                lineHeight: Style.dp(22)
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
        }

        ListView {
            anchors.top: collectibleImageDetails.bottom
            anchors.topMargin: Style.dp(32)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.dp(20)
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: 3
            delegate: StatusExpandableItem {
                width: parent.width
                height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter

                primaryText: index === 0 ? qsTr("Properties") : index === 1 ? qsTr("Levels") : qsTr("Stats")
                type: StatusExpandableItem.Type.Tertiary
                expandableComponent: index === 0 ? properties : index === 1 ? rankings : stats
                visible: index === 0 ? (!!assetProperties ? assetProperties.rowCount() !== 0 : false) :
                         index === 1 ? (!!assetRankings ? assetRankings.rowCount() !== 0 : false) :
                                       (!!assetStats ? assetStats.rowCount() !== 0 : false)
            }
        }
    }

    Component {
        id: properties

        Flow {
            width: parent.width
            spacing: Style.dp(10)

            Repeater {
                model: assetProperties
                Rectangle {
                    id: containerRect
                    height: Style.dp(52)
                    width: Style.dp(147)
                    color: "transparent"
                    border.color: Theme.palette.baseColor2
                    border.width: Style.dp(1)
                    radius: Style.current.radius
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Style.dp(6)
                        StatusBaseText {
                            width: containerRect.width - Style.dp(12)

                            color: Theme.palette.baseColor1
                            font.pixelSize: Style.current.additionalTextSize
                            lineHeight: Style.dp(18)
                            lineHeightMode: Text.FixedHeight
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            text: model.traitType
                            font.capitalization: Font.Capitalize
                        }
                        StatusBaseText {
                            width: containerRect.width - Style.dp(12)

                            color: Theme.palette.directColor1
                            font.pixelSize: Style.current.primaryTextFontSize
                            lineHeight: Style.dp(22)
                            lineHeightMode: Text.FixedHeight
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: model.value
                        }
                    }
                }
            }
        }
    }

    // To-do change to progress bar one design is finalized
    Component {
        id: rankings

        Column {
            width: parent.width
            spacing: Style.dp(10)

            Repeater {
                model: assetRankings
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Style.dp(52)
                    color: Theme.palette.baseColor4
                    StatusBaseText {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.dp(10)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.palette.baseColor1
                        font.pixelSize: Style.current.primaryTextFontSize
                        lineHeight: Style.dp(22)
                        lineHeightMode: Text.FixedHeight
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                        text: model.traitType
                        font.capitalization: Font.Capitalize
                    }
                    StatusBaseText {
                        anchors.right: parent.right
                        anchors.rightMargin: Style.dp(10)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.palette.directColor1
                        font.pixelSize: Style.current.primaryTextFontSize
                        lineHeight: Style.dp(22)
                        lineHeightMode: Text.FixedHeight
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        text: RootStore.getCollectionMaxValue(model.traitType, model.value, model.maxValue, collectionIndex)
                    }
                }
            }
        }
    }

    // To-do change to progress bar one design is finalized
    Component {
        id: stats

        Column {
            width: parent.width
            spacing: Style.dp(10)

            Repeater {
                model: assetStats
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Style.dp(52)
                    color: Theme.palette.baseColor4
                    StatusBaseText {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.dp(10)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.palette.baseColor1
                        font.pixelSize: Style.current.primaryTextFontSize
                        lineHeight: Style.dp(22)
                        lineHeightMode: Text.FixedHeight
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                        text: model.traitType
                        font.capitalization: Font.Capitalize
                    }
                    StatusBaseText {
                        anchors.right: parent.right
                        anchors.rightMargin: Style.dp(10)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.palette.directColor1
                        font.pixelSize: Style.current.primaryTextFontSize
                        lineHeight: Style.dp(22)
                        lineHeightMode: Text.FixedHeight
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        text: RootStore.getCollectionMaxValue(model.traitType, model.value, model.maxValue, collectionIndex)
                    }
                }
            }
        }
    }
}
