package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"os"
)

func indexHandler(w http.ResponseWriter, r *http.Request) {

	// Save a copy of this request for debugging.
	requestDump, err := httputil.DumpRequest(r, true)
	if err != nil {
  		fmt.Println(err)
	} else {
		fmt.Println(string(requestDump))
	}

	w.Write([]byte("<h1>Hello World!</h1>"))
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/", indexHandler)
	http.ListenAndServe(":"+port, mux)
}