package main

import (
	"log"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/pkg/browser"
	webview "github.com/webview/webview_go"
)

func main() {
	// Serve files from the ./generated directory
	fileServer := http.FileServer(http.Dir("./generated"))

	// Serve the index.html file on the root path "/"
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Set cache-control headers before serving the file
		w.Header().Set("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0")

		if r.URL.Path != "/" {
			// Let the file server handle non-root requests
			fileServer.ServeHTTP(w, r)
			return
		}

		// Serve the root path
		http.ServeFile(w, r, "./src/index.html")
	})

	openExternally := true

	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	port := strconv.Itoa(10000 + r.Intn(9999))
	pageURL := "http://localhost:" + port

	if openExternally {
		err := browser.OpenURL(pageURL)
		if err != nil {
			log.Fatal(err)
		}
		http.ListenAndServe(":"+port, nil)
	} else {
		// Start WebView
		w := webview.New(true)
		defer w.Destroy()
		w.SetTitle("WC modal")
		w.SetSize(1280, 1024, webview.HintNone)

		go http.ListenAndServe(":"+port, nil)

		w.Navigate(pageURL)
		w.Run()
	}
}
