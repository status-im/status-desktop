import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusCommunityCard
   \inherits Rectangle
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a community card item that provides relevant information about a community model. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-rectangle.html}{Rectangle}.

   The \c StatusCommunityCard is a community card clickable item that represents a data model. The data model is commonly a JavaScript array or a ListModel object.

   Example of how the component looks like:
   \image status_community_card.png
   Example of how to use it:
   \qml
        StatusCommunityCard {
            locale: "en"
            communityId: model.communityId
            loaded: model.available
            asset.source: model.icon
            name: model.name
            description: model.description
            members: model.members
            popularity: model.popularity
            categories:  model.categories

            onClicked: { d.navigateToCommunity(communityId) }
        }
   \endqml
   For a list of components available see StatusQ.
*/
Rectangle {
    id: root

    property int cardSize: StatusCommunityCard.Size.Big
    enum Size {
        Big,
        Small
    }
    /*!
       \qmlproperty bool StatusCommunityCard::memberCountVisible
       This property sets the member's count visibility.
    */
    property bool memberCountVisible: true
    /*!
       \qmlproperty bool StatusCommunityCard::hovered
       This property indicates whether the card contains mouse.
    */
    property bool hovered: sensor.containsMouse
    /*!
       \qmlproperty int StatusCommunityCard::titleFontSize
       This property holds the title's font size.
    */
    property int titleFontSize: 19
    /*!
       \qmlproperty int StatusCommunityCard::descriptionFontSize
       This property holds the description's font size.
    */
    property int descriptionFontSize: 15
    /*!
       \qmlproperty string StatusCommunityCard::communityId
       This property holds the community identifier value.
    */
    property string communityId: ""
    /*!
       \qmlproperty bool StatusCommunityCard::loaded
       This property holds a boolean value that represents if the community information is loaded or not.
    */
    property bool loaded: true
    /*!
       \qmlproperty string StatusCommunityCard::name
       This property holds the community name.
    */
    property string name: ""
    /*!
       \qmlproperty string StatusCommunityCard::description
       This property holds the community description.
    */
    property string description: ""
    /*!
       \qmlproperty int StatusCommunityCard::members
       This property holds the community members value.
    */
    property int members: 0
    /*!
       \qmlproperty int StatusCommunityCard::activeUsers
       This property holds the community active users value.
    */
    property int activeUsers: 0
    /*!
       \qmlproperty int StatusCommunityCard::popularity
       This property holds the community popularity (community rate).
    */
    property int popularity: 0
    /*!
       \qmlproperty string StatusCommunityCard::categories
       This property holds the data that will be populated as the tags row of the community.

       Here an example of the model roles expected:
       \qml
            categories: ListModel {
                ListElement { name: "gaming"; emoji: "🎮"; selected: false}
                ListElement { name: "art"; emoji: "🖼️️"; selected: false}
                ListElement { name: "crypto"; emoji: "💸"; selected: false}
                ListElement { name: "nsfw"; emoji: "🍆"; selected: false}
                ListElement { name: "markets"; emoji: "💎"; selected: false}
            }
       \endqml
    */
    property ListModel categories: ListModel {}
    /*!
       \qmlproperty var StatusCommunityCard::locale
       This property holds the application locale used to give format to members number representation.
    */
    property var locale: Qt.locale()
    /*!
       \qmlproperty url StatusCommunityCard::banner
       This property holds the community banner image url.
    */
    property url banner: ""
    /*!
       \qmlproperty color StatusCommunityCard::communityColor
       This property holds the community color.
       If not provided, default value in Light Theme is "#4360DF" and in Dark Theme is "#88B0FF".
    */
    property color communityColor: Theme.palette.primaryColor1
    /*!
       \qmlproperty url StatusCommunityCard::tokenLogo
       This property holds the image of the token needed if the community is private.
    */
    property url tokenLogo: ""

    /*!
       \qmlproperty Item StatusCommunityCard::rigthHeaderComponent
       This property holds an extra info header component that will be displayed on top right of the card.
       Example: Community token permissions row.
    */
    property alias rigthHeaderComponent: rightHeaderLoader.sourceComponent

    /*!
       \qmlproperty Item StatusCommunityCard::bottomRowComponent
       This property holds an extra info bottom row component that will be displayed on bottom left of the card.
       Example: Community token permissions row.
    */
    property alias bottomRowComponent: bottomRowLoader.sourceComponent
    /*!
       \qmlproperty color StatusCommunityCard::descriptionFontColor
       This property holds the description font color.
       If not provided, default value in Light Theme is "#000000" and in Dark Theme is "#FFFFFF".
    */
    property color descriptionFontColor: Theme.palette.directColor1

    /*!
       \qmlproperty StatusAssetSettings StatusCommunityCard::asset
       This property holds the card's asset settings for the logo image.
    */
    property StatusAssetSettings asset: StatusAssetSettings {
        height: 40
        width: 40
    }

    /*!
        \qmlsignal StatusCommunityCard::clicked(string communityId)
        This signal is emitted when the card item is clicked.
    */
    signal clicked(var mouse, string communityId)

    QtObject {
        id: d
        readonly property int cardWidth: 335
        readonly property int bannerHeight: (root.cardSize === StatusCommunityCard.Size.Big) ? 64 : 55
        readonly property int cardHeigth: (root.cardSize === StatusCommunityCard.Size.Big) ? 190 : 119
        readonly property int totalHeigth:  (root.cardSize === StatusCommunityCard.Size.Big) ? 230 : 144
        readonly property int margins: 12
        readonly property int bannerRadius: (root.cardSize === StatusCommunityCard.Size.Big) ? 20 : 8
        readonly property int bannerRadiusHovered: (root.cardSize === StatusCommunityCard.Size.Big) ? 30 : 16
        readonly property int cardRadius: (root.cardSize === StatusCommunityCard.Size.Big) ? 16 : 8
        readonly property color cardColor: Theme.palette.name === "light" ? Theme.palette.indirectColor1 : Theme.palette.baseColor2
        readonly property color fontColor: Theme.palette.directColor1
        readonly property color loadingColor1: Theme.palette.baseColor5
        readonly property color loadingColor2: Theme.palette.baseColor4
        readonly property int titleFontWeight: (root.cardSize === StatusCommunityCard.Size.Big) ? Font.Bold : Font.Medium

        function numberFormat(number) {
            var res = number
            const million = 1000000
            const ks = 1000
            if(number > million) {
                res = number / million
                res = Number(number / million).toLocaleString(root.locale, 'f', 1) + 'M'
            }
            else if(number > ks) {
                res = number / ks
                res = Number(number / ks).toLocaleString(root.locale, 'f', 1) + 'K'
            }
            else
                res = Number(number).toLocaleString(root.locale, 'f', 0)
            return res
        }
    }

    implicitWidth: d.cardWidth
    implicitHeight: d.totalHeigth
    radius: d.bannerRadius
    color: "transparent"
    layer.enabled: true
    layer.effect: DropShadow {
        source: root
        horizontalOffset: 0
        verticalOffset: 2
        radius: sensor.containsMouse ? d.bannerRadiusHovered : d.bannerRadius
        samples: 25
        spread: 0
        color: sensor.containsMouse ? Theme.palette.backdropColor : Theme.palette.dropShadow
    }

    // Community banner:
    Item {
        id: banner

        anchors.top: parent.top
        width: parent.width
        height: d.bannerHeight

        Rectangle {
            id: mask

            anchors.fill: parent

            radius: d.bannerRadius
            color: root.loaded ? root.communityColor : d.loadingColor2

            // hide when image is loaded to avoid glitches on the edge
            visible: !root.loaded || image.status !== Image.Ready
        }

        Image {
            id: image

            anchors.fill: parent

            source: root.banner
            fillMode: Image.PreserveAspectCrop
            smooth: true
            visible: false
            cache: false
        }

        OpacityMask {
            anchors.fill: image

            visible: root.loaded
            source: image
            maskSource: mask
        }
    }

    // Community logo:
    Rectangle {
        z: content.z + 1
        anchors.top: parent.top
        anchors.topMargin: (root.cardSize === StatusCommunityCard.Size.Big) ? 16 : 8
        anchors.left: parent.left
        anchors.leftMargin: 12
        width: root.asset.width + 4
        height: width
        radius: width / 2
        color: root.loaded ? d.cardColor : d.loadingColor1

        StatusRoundedImage {
            visible: root.loaded
            anchors.centerIn: parent
            width: parent.width - 4
            height: width
            image.source: root.asset.source
            color: "transparent"
        }
    } // End of community logo

    // Content card
    Rectangle {
        id: content
        z: banner.z + 1
        visible: root.loaded
        anchors.top: parent.top
        anchors.topMargin: (root.cardSize === StatusCommunityCard.Size.Big) ? 40 : 25
        width: parent.width
        height: d.cardHeigth
        color: d.cardColor
        radius: d.cardRadius
        border.color: root.border.color
        clip: true

        // Right header extra info component
        Loader {
            id: rightHeaderLoader
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: anchors.topMargin
        }

        // Community info
        ColumnLayout {
            anchors.top: parent.top
            anchors.topMargin: (root.cardSize === StatusCommunityCard.Size.Big) ? 32 : 26
            anchors.left: parent.left
            anchors.leftMargin: d.margins
            anchors.right: parent.right
            anchors.rightMargin: d.margins
            spacing: (root.cardSize === StatusCommunityCard.Size.Big) ? 6 : 0
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: (root.cardSize === StatusCommunityCard.Size.Big)
                Layout.preferredHeight: 22
                text: root.name
                font.weight: d.titleFontWeight
                font.pixelSize: root.titleFontSize
                color: d.fontColor
                elide: Text.ElideRight
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: (root.cardSize === StatusCommunityCard.Size.Big)
                Layout.preferredHeight: 16
                text: root.description
                font.pixelSize: root.descriptionFontSize
                lineHeight: 1.2
                color: root.descriptionFontColor
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                clip: true
            }
        }
        ColumnLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: d.margins
            anchors.right: parent.right
            anchors.rightMargin: d.margins
            anchors.bottomMargin: d.margins
            spacing: (root.cardSize === StatusCommunityCard.Size.Big) ? 18 : 0
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 20
                // Members
                visible: root.memberCountVisible
                Row {
                    height: membersTxt.height
                    spacing: 4
                    StatusIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "tiny/members"
                        width: 16
                        height: 16
                    }
                    StatusBaseText {
                        id: membersTxt
                        Layout.alignment: Qt.AlignVCenter
                        text: d.numberFormat(root.members)
                        font.pixelSize: 15
                        color: d.fontColor
                    }
                }
                // Active users:
                Row {
                    height: activeUsersTxt.height
                    spacing: 4
                    StatusIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "tiny/flash"
                        width: 14
                        height: 14
                    }
                    StatusBaseText {
                        id: activeUsersTxt
                        Layout.alignment: Qt.AlignVCenter
                        text: d.numberFormat(root.activeUsers)
                        font.pixelSize: 15
                        color: d.fontColor
                    }
                }
            }

            // Bottom Row extra info component
            Loader {
                id: bottomRowLoader
                Layout.fillWidth: (!!item && item.width===0)
                Layout.preferredHeight: 24
                active: ((root.categories.count > 0) || !!root.bottomRowComponent)
                sourceComponent: tagsListComponent
            }

            Component {
                id: tagsListComponent
                StatusRollArea {
                    arrowsGradientColor: d.cardColor

                    // TODO: Replace by `StatusListItemTagRow` - To be done!
                    content: Row {
                        spacing: 8
                        clip: true

                        Repeater {
                            model: root.categories
                            delegate: StatusListItemTag {
                                bgColor: "transparent"
                                bgRadius: 20
                                bgBorderColor: Theme.palette.baseColor2
                                height: 24
                                closeButtonVisible: false
                                asset.emoji: model.emoji
                                asset.width: 24
                                asset.height: 24
                                asset.color: "transparent"
                                asset.isLetterIdenticon: true
                                title: model.name
                                titleText.font.pixelSize: 13
                                titleText.color: d.fontColor
                            }
                        }
                    }
                }
            }
        }
    } // End of content card

    // Loading card
    Rectangle {
        visible: !root.loaded
        anchors.top: parent.top
        anchors.topMargin: (root.cardSize === StatusCommunityCard.Size.Big) ? 40 : 23
        width: parent.width
        height: d.cardHeigth
        color: d.cardColor
        radius: d.cardRadius
        clip: true
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: anchors.topMargin
            width: 48
            height: 24
            color: d.loadingColor2
            radius: 200
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 32
            anchors.margins: d.margins
            clip: true
            spacing: 9
            Rectangle {
                width: 84
                height: 16
                color: d.loadingColor1
                radius: 5
            }
            Rectangle {
                width: 311
                height: 16
                color: d.loadingColor1
                radius: 5
            }
            Rectangle {
                width: 271
                height: 16
                color: d.loadingColor1
                radius: 5
            }
            Row {
                Layout.topMargin: 22 - 9
                spacing: 16
                Repeater {
                    model: 2
                    delegate: Row {
                        spacing: 4
                        Rectangle {
                            width: 14
                            height: 14
                            color: d.loadingColor1
                            radius: width / 2
                        }
                        Rectangle {
                            width: 50
                            height: 12
                            color: d.loadingColor2
                            radius: 5
                        }
                    }
                }
            }
            Row {
                Layout.topMargin: 21 - 9
                spacing: 8
                Repeater {
                    model: 3
                    delegate:
                    Rectangle {
                        width: 76
                        height: 24
                        color: d.loadingColor2
                        radius: 20
                    }
                }
            }
        }
    } // End of loading card

    MouseArea {
        id: sensor
        enabled: root.loaded
        anchors.fill: parent
        cursorShape: root.loaded ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: root.clicked(mouse ,root.communityId)
    }
}
