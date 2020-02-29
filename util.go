package main

import (
	"./stdlib/strings"
)

// "fmt" => "/stdlib/fmt"
func normalizeImportPath(path string) string {
	if len(path) > 9 {
		if path[0] == '.' {
			bp := []byte(path)
			var path2 []byte
			for i, b := range bp {
				if i == 0 {
					continue
				}
				path2 = append(path2, b)
			}
			return string(path2)
		}
	} else {
		// "fmt" => "/stdlib/fmt"
		return "/stdlib/" + path
	}
	return ""
}

func getBaseNameFromImport(path string) string {
	if strings.Contains(path, "/") {
		words := strings.Split(path, "/")
		r := words[len(words)-1]
		return r
	} else {
		return path
	}

}

func getIndex(item string, list []string) int {
	for id, v := range list {
		if v == item {
			return id
		}
	}
	return -1
}

func inArray(item string, list []string) bool {
	for _, v := range list {
		if v == item {
			return true
		}
	}
	return false
}
