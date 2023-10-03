import QtQuick 2.15


Item {
    id: root

    property bool propagateClipping: false
    property bool showNonVisualItems: false
    property alias showScreenshot: image.visible

    required property Item sourceItem

    readonly property ListModel model: ListModel {}

    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight

    signal clicked(int index)

    Component {
        id: inspectionItemComponent

        InspectionItem {
            required property int index

            onClicked: root.clicked(index)
        }
    }

    Image {
        id: image
    }

    function itemsDepthFirst(root) {
        const items = []

        function iterate(item, parentIndex, level) {
            if (!item.visible || item.opacity === 0)
                return

            const idx = items.length
            items.push({item, parentIndex, level})

            for (let i = 0; i < item.children.length; i++)
                iterate(item.children[i], idx, level + 1)
        }

        iterate(root, -1, 0)
        return items
    }

    Component.onCompleted: {
        root.sourceItem.grabToImage(result => image.source = result.url)

        const items = itemsDepthFirst(root.sourceItem)

        const placeholders = []
        const modelItems = []

        items.forEach((entry, index) => {
            const {item, parentIndex, level} = entry
            const isRoot = parentIndex === -1

            const parent = isRoot ? root : placeholders[parentIndex]
            const visualParent = isRoot ? root
                                        : (parent.isVisual
                                           ? (parent.background || parent)
                                           : parent.visualParent)

            const x = isRoot ? 0 : item.x
            const y = isRoot ? 0 : item.y

            const name = InspectionUtils.simpleName(item)
            const visual = InspectionUtils.isVisual(item) || !!item.background
            const clip = item.clip

            const props = {
                index, name, x, y,
                objName: item.objectName,
                width: item.width,
                height: item.height,
                z: item.z,
                isVisual: visual,
                visualParent,
                visualRoot: root,
                clip: Qt.binding(() => root.propagateClipping && item.clip),
                showNonVisual: Qt.binding(() => root.showNonVisualItems)
            }

            const placeholder = inspectionItemComponent.createObject(
                              parent, props)

            const modelEntryProps = {
                name, visual, level,
                item: placeholder
            }

            modelItems.push(modelEntryProps)
            placeholders.push(placeholder)
        })

        root.model.append(modelItems)
    }
}
