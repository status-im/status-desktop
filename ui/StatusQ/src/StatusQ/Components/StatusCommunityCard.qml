import QtQuick 2.13
import QtQuick.Layouts 1.14

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
            logo: model.icon
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
       \qmlproperty url StatusCommunityCard::logo
       This property holds the community logo source.
    */
    property url logo: ""
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
       \qmlproperty string StatusCommunityCard::locale
       This property holds the application locale used to give format to members number representation.
       If not provided, default value is "en".
    */
    property string locale: "en"

    /*!
        \qmlsignal StatusCommunityCard::clicked(string communityId)
        This signal is emitted when the card item is clicked.
    */
    signal clicked(string communityId)

    QtObject {
        id: d
        property int dMargins: 12
    }

    width: 400 // by design
    height: 230 // by design
    border.color: Theme.palette.baseColor2
    color: sensor.containsMouse ? Theme.palette.baseColor4 : "transparent"
    radius: 8
    clip: true

    // Community Card:
    ColumnLayout {
        visible: root.loaded
        anchors.fill: parent
        anchors.margins: d.dMargins
        clip: true
        spacing: 4       

        StatusRoundedImage {
            width: 40
            height: 40
            image.source: root.logo
            color: "transparent"
        }

        // TODO: Add here new component for community permissions / restrictions
        // ...

        RowLayout {
            Layout.topMargin: 8

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: root.name
                font.weight: Font.Bold
                font.pixelSize: 17
                color: Theme.palette.directColor1
            }

            StatusIcon {
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 6
                icon: "tiny/tiny-contact"
                width: 10
                height: 10
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: Number(root.members).toLocaleString(Qt.locale(locale), 'f', 0)
                font.pixelSize: 13
                color: Theme.palette.directColor1
                horizontalAlignment: Text.AlignLeft
            }
        }

        StatusBaseText {
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: root.description
            font.pixelSize: 15
            color: Theme.palette.directColor1
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            clip: true
        }

        // TODO: Replace by `StatusListItemTagRow` - To be done!
        Row {
            visible: root.categories.count > 0
            Layout.bottomMargin: 4
            width: 324 // by design
            spacing: 8
            clip: true

            Repeater {
                model: root.categories
                delegate: StatusListItemTag {
                    border.color: Theme.palette.baseColor2
                    color: "transparent"
                    height: 32
                    radius: 36
                    closeButtonVisible: false
                    icon.emoji: model.emoji
                    icon.height: 32
                    icon.width: icon.height
                    icon.color: "transparent"
                    icon.isLetterIdenticon: true
                    title: model.name
                    titleText.font.pixelSize: 15
                    titleText.color: Theme.palette.primaryColor1
                }
            }
        }
    }

    // Loading Card
    ColumnLayout {
        visible: !root.loaded
        anchors.fill: parent
        anchors.margins: d.dMargins
        clip: true
        spacing: 9

        Rectangle {
            width: 40
            height: 40
            color: Theme.palette.baseColor2
            radius: width / 2
        }

        RowLayout {
            Layout.topMargin: 8
            Rectangle {
                Layout.alignment: Qt.AlignBottom
                Layout.topMargin: 8
                width: 84
                height: 16
                color: Theme.palette.baseColor2
                radius: 5
            }

            Rectangle {
                Layout.leftMargin: 8
                Layout.alignment: Qt.AlignBottom
                width: 14
                height: 14
                color: Theme.palette.baseColor2
                radius: width / 2
            }

            Rectangle {
                Layout.alignment: Qt.AlignBottom
                width: 50
                height: 12
                color: Theme.palette.baseColor2
                radius: 5
            }
        }

        Rectangle {
            width: 311
            height: 16
            color: Theme.palette.baseColor2
            radius: 5
        }

        Rectangle {
            width: 271
            height: 16
            color: Theme.palette.baseColor2
            radius: 5
        }

        // Filler
        Item { Layout.fillHeight: true }

        Row {
            Layout.bottomMargin: 4
            spacing: 8

            Repeater {
                model: 3
                delegate:
                Rectangle {
                    width: 76
                    height: 24
                    color: Theme.palette.baseColor2
                    radius: 20
                }
            }
        }
    }

    MouseArea {
        id: sensor
        enabled: root.loaded
        anchors.fill: parent
        cursorShape: root.loaded ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true

        onClicked: root.clicked(root.communityId)
    }
}
