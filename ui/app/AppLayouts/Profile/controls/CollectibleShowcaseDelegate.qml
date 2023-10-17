import QtQuick 2.15

import utils 1.0

ShowcaseDelegate {
    title: !!showcaseObj ? `${showcaseObj.name}` || `#${showcaseObj.id}` : ""
    secondaryTitle: !!showcaseObj && !!showcaseObj.collectionName ? showcaseObj.collectionName : ""
    hasImage: !!showcaseObj && !!showcaseObj.imageUrl

    icon.source: hasImage ? showcaseObj.imageUrl : ""
    bgRadius: Style.current.radius
    assetBgColor: !!showcaseObj && !!showcaseObj.backgroundColor ? showcaseObj.backgroundColor : "transparent"
}
