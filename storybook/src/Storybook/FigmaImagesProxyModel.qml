import QtQuick 2.15

ListModel {
    id: root

    required property FigmaLinksCache figmaLinksCache
    property alias sourceModel: d.model

    readonly property Instantiator _d: Instantiator {
        id: d

        property int idCounter: 0

        model: 0

        delegate: QtObject {
            id: delegate

            property int uniqueId

            Component.onCompleted: {
                append({
                    rawLink: model.link,
                    imageLink: "",
                    uniqueId: d.idCounter
                })

                uniqueId = d.idCounter
                d.idCounter++

                figmaLinksCache.getImageUrl(model.link, link => {
                    if (delegate && link !== null)
                        root.setProperty(model.index, "imageLink", link)
                })
            }
        }

        onObjectRemoved: {
            for (let i = 0; i < root.count; i++) {
                if (root.get(i).uniqueId === object.uniqueId) {
                    root.remove(i)
                    break
                }
            }
        }
    }
}
