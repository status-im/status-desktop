pragma Singleton

import QtQml 2.14

QtObject {
    function decomposeLink(link) {
        const fileRegex = /www\.figma\.com\/file\/([a-zA-Z0-9]+)/
        const fileMatch = link.match(fileRegex)

        const nodeIdRegex = /node-id=([0-9A-Za-z%]+)/
        const nodeIdMatch = link.match(nodeIdRegex)

        return {
            file: fileMatch[1],
            nodeId: nodeIdMatch[1]
        }
    }

    function getLinks(token, file, nodeIds, cb) {

        console.assert(nodeIds.length > 0)

        const ids = nodeIds.join()
        const url = `https://api.figma.com/v1/images/${file}?ids=${ids}`

        const http = new XMLHttpRequest()
        http.open("GET", url, true)
        http.setRequestHeader("X-FIGMA-TOKEN", token)

        http.onreadystatechange = () => {
            if (http.readyState !== 4)
                return

            if (http.status === 200)
                cb(null, JSON.parse(http.response).images)
            else
                cb(`Failed to fetch figma image links, status: ${http.status}`)
        }

        http.send()
    }
}
