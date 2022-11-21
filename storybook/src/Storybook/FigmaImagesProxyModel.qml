import QtQuick 2.14

ListModel {
    /* required */ property FigmaLinksCache figmaLinksCache
    property alias sourceModel: d.model

    readonly property Instantiator _d: Instantiator {
        id: d

        model: 0

        delegate: QtObject {
            id: delegate

            Component.onCompleted: {
                append({
                    rawLink: model.link,
                    imageLink: ""
                })

                figmaLinksCache.getImageUrl(model.link, link => {
                    if (delegate)
                        setProperty(model.index, "imageLink", link)
                })
            }
        }

        onObjectRemoved: console.warn("FigmaImagesProxyModel: removing items from the source model is not supported!")
    }
}
