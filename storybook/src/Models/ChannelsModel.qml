import QtQuick 2.0

ListModel {
    Component.onCompleted:
        append([
                   {
                       key: "wellcome",
                       iconSource: ModelsData.tokens.inch,
                       name: "#wellcome"
                   },
                   {
                       key: "general",
                       iconSource: ModelsData.tokens.inch,
                       name: "#general"
                   }
               ])
}
