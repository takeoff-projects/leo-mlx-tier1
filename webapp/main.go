package main

import (
	"encoding/json"
	"bytes"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
	"context"
	"github.com/gorilla/mux"

	"cloud.google.com/go/datastore"
)

var projectID string

func main() {
	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}
	log.Printf("GOOGLE_CLOUD_PROJECT is set to %s", projectID)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"

	}
	log.Printf("Port set to: %s", port)

	fs := http.FileServer(http.Dir("assets"))
	myRouter := mux.NewRouter().StrictSlash(true)

	// This serves the static files in the assets folder
	myRouter.Handle("/assets/", http.StripPrefix("/assets/", fs))

	// The rest of the routes
	myRouter.HandleFunc("/", indexHandler)
	myRouter.HandleFunc("/about", aboutHandler)
	myRouter.HandleFunc("/items", getItemsHandler).Methods("GET")
	myRouter.HandleFunc("/items/{id}", getItemByIdHandler).Methods("GET")


	log.Printf("Webserver listening on Port: %s", port)
	http.ListenAndServe(":"+port, myRouter)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	var decs []Decision
	decs, error := GetDecs()
	if error != nil {
		fmt.Print(error)
	}

	data := HomePageData{
		PageTitle: "Some search from github",
		Decs: decs,
	}

	var tpl = template.Must(template.ParseFiles("templates/index.html", "templates/layout.html"))

	buf := &bytes.Buffer{}
	err := tpl.Execute(buf, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	buf.WriteTo(w)
	log.Println("Home Page Served")
}

func aboutHandler(w http.ResponseWriter, r *http.Request) {
	data := AboutPageData{
		PageTitle: "About this project",
	}

	var tpl = template.Must(template.ParseFiles("templates/about.html", "templates/layout.html"))

	buf := &bytes.Buffer{}
	err := tpl.Execute(buf, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	buf.WriteTo(w)
	log.Println("About Page Served")
}

// HomePageData for Index template
type HomePageData struct {
	PageTitle string
	Decs []Decision
}

// AboutPageData for About template
type AboutPageData struct {
	PageTitle string
}

type Decision struct {
	Added   time.Time `datastore:"added"`
	Link    string    `datastore:"link"`
	Name    string     // The ID used in the datastore.
}

func GetDecs() ([]Decision, error) {

	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}

	var decs []Decision
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	// Create a query to fetch all Pet entities".
	query := datastore.NewQuery("Decision").Order("-added")
	keys, err := client.GetAll(ctx, query, &decs)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}

	// Set the id field on each Task from the corresponding key.
	for i, key := range keys {
		decs[i].Name = key.Name
	}

	client.Close()
	return decs, nil
}


func getItemsHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getItems")
	var decs []Decision
        decs, error := GetDecs()
        if error != nil {
                fmt.Print(error)
        }
	json.NewEncoder(w).Encode(decs)
}

func getItemByIdHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getItemById")
	vars := mux.Vars(r)
	key := vars["id"]
        projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
        if projectID == "" {
                log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
        }

	var dec Decision
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
        if err != nil {
                log.Fatalf("Could not create datastore client: %v", err)
        }

	_, err2 := client.Get(ctx, key, dec)
        if err2 != nil {
                fmt.Println(err2)
        }

	json.NewEncoder(w).Encode(dec)

}
