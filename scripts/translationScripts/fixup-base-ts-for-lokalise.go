package main

import (
	"encoding/xml"
	"fmt"
	"os"
	"strings"
)

// TS represents the root TS element
type TS struct {
	XMLName        xml.Name  `xml:"TS"`
	Language       string    `xml:"language,attr"`
	SourceLanguage string    `xml:"sourcelanguage,attr"`
	Contexts       []Context `xml:"context"`
}

// Context represents a context element
type Context struct {
	Name     string    `xml:"name"`
	Messages []Message `xml:"message"`
}

// Message represents a message element
type Message struct {
	Numerus     string      `xml:"numerus,attr,omitempty"`
	Source      string      `xml:"source"`
	Comment     string      `xml:"comment,omitempty"`
	Translation Translation `xml:"translation"`
	Extra       []xml.Token `xml:",any"` // For any extra elements like unfinished
}

// Translation represents a translation element, handling numerus forms
type Translation struct {
	Type         string        `xml:"type,attr,omitempty"`
	Text         string        `xml:",chardata"`
	NumerusForms []NumerusForm `xml:"numerusform,omitempty"`
}

// NumerusForm represents a numerusform element
type NumerusForm struct {
	Text string `xml:",chardata"`
}

func main() {
	// Relative paths from project root
	baseFile := "../../ui/i18n/qml_base_en.ts"
	pluralFile := "../../ui/i18n/qml_en.ts"
	outputFile := "../../ui/i18n/qml_base_lokalise_en.ts"

	// Parse the base TS file
	baseData, err := os.ReadFile(baseFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading %s: %v\n", baseFile, err)
		os.Exit(1)
	}
	var baseTS TS
	if err := xml.Unmarshal(baseData, &baseTS); err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing %s: %v\n", baseFile, err)
		os.Exit(1)
	}

	// Parse the plural TS file
	pluralData, err := os.ReadFile(pluralFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading %s: %v\n", pluralFile, err)
		os.Exit(1)
	}
	var pluralTS TS
	if err := xml.Unmarshal(pluralData, &pluralTS); err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing %s: %v\n", pluralFile, err)
		os.Exit(1)
	}

	// Create a dictionary for quick lookup of plural translations by source
	pluralLookup := make(map[string]Translation)
	for _, context := range pluralTS.Contexts {
		for _, message := range context.Messages {
			if message.Source != "" {
				pluralLookup[message.Source] = message.Translation
			}
		}
	}

	// Process each message in the base file
	for i := range baseTS.Contexts {
		context := &baseTS.Contexts[i]
		contextName := context.Name
		for j := range context.Messages {
			message := &context.Messages[j]
			// Add comment if missing
			if message.Comment == "" {
				message.Comment = contextName
			}

			if message.Numerus == "yes" && message.Source != "" {
				if pluralTrans, exists := pluralLookup[message.Source]; exists {
					message.Translation = pluralTrans
					// Clean up whitespace in text and numerus forms
					message.Translation.Text = strings.TrimSpace(message.Translation.Text)
					for k := range message.Translation.NumerusForms {
						message.Translation.NumerusForms[k].Text = strings.TrimSpace(message.Translation.NumerusForms[k].Text)
					}
					// Remove unfinished type
					if message.Translation.Type == "unfinished" {
						message.Translation.Type = ""
					}
				}
			} else {
				// Set translation to source, trimmed
				message.Translation.Text = strings.TrimSpace(message.Source)
				message.Translation.NumerusForms = nil // Clear numerus forms
				// Remove unfinished type
				if message.Translation.Type == "unfinished" {
					message.Translation.Type = ""
				}
			}
		}
	}

	// Set language attributes
	baseTS.Language = "en"
	baseTS.SourceLanguage = "en"

	// Write the modified XML to output file
	outputData, err := xml.MarshalIndent(baseTS, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error marshaling XML: %v\n", err)
		os.Exit(1)
	}
	// Add XML declaration
	outputData = []byte(xml.Header + string(outputData))
	if err := os.WriteFile(outputFile, outputData, 0644); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing to %s: %v\n", outputFile, err)
		os.Exit(1)
	}
	fmt.Printf("Successfully transformed %s to %s\n", baseFile, outputFile)
}
