package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
)

var qrcExtensions = map[string]bool{
	".qml":  true,
	".js":   true,
	".svg":  true,
	".png":  true,
	".ico":  true,
	".icns": true,
	".mp3":  true,
	".wav":  true,
	".otf":  true,
	".ttf":  true,
	".webm": true,
	".qm":   true,
	".txt":  true,
	".gif":  true,
	".json": true,
	".mdwn": true,
	".html": true,
}

func main() {
	sourceDirName := flag.String("source", "", "source dir containing ui files")
	qrcFileName := flag.String("output", "resources.qrc", "output filename")
	flag.Parse()
	if flag.NFlag() == 0 {
		flag.Usage()
		return
	}

	qrcFile, err := os.Create(*qrcFileName)
	if err != nil {
		log.Fatalf("Failed creating qrc file: %s", err)
	}
	defer qrcFile.Close()

	qrcFile.WriteString("<!DOCTYPE RCC>\n")
	qrcFile.WriteString("<RCC version=\"1.0\">\n")
	qrcFile.WriteString("  <qresource>\n")

	counter := 0
	err = filepath.Walk(*sourceDirName,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if info.IsDir() && (info.Name() == "vendor" || info.Name() == "tests" || info.Name() == "StatusQ" || info.Name() == "node_modules") {
				return filepath.SkipDir
			}
			if !info.IsDir() {
				ext := filepath.Ext(path)
				base := filepath.Base(path)
				if qrcExtensions[ext] || base == "qmldir" {
					counter++
					fixedPath := strings.ReplaceAll(path, "\\", "/")
					fixedPath = "./" + strings.TrimPrefix(fixedPath, *sourceDirName)
					qrcFile.WriteString("      <file>" + fixedPath + "</file>\n")
				}
			}
			return nil
		})

	qrcFile.WriteString("  </qresource>\n")
	qrcFile.WriteString("</RCC>")

	fmt.Printf("%d resources added\n", counter)
}
