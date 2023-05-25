import QtQuick 2.15

ShowcaseDelegate {
    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj && !!showcaseObj.amISectionAdmin ? qsTr("Admin") : qsTr("Member")
    hasImage: !!showcaseObj && !!showcaseObj.image

    icon.name: !!showcaseObj ? showcaseObj.name : ""
    icon.source: !!showcaseObj ? showcaseObj.image : ""
    icon.color: !!showcaseObj ? showcaseObj.color : "transparent"
}
