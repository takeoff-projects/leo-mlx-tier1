package main

import (
	"fmt"
	"log"
	"os"
	"time"
	"context"

	"cloud.google.com/go/datastore"
)

var projectID string

type Decision struct {
	Added   time.Time `datastore:"added"`
	Link    string    `datastore:"link"`
	Name    string     // The ID used in the datastore.
}

func main() {

	var decs []Decision

	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}
	log.Printf("GOOGLE_CLOUD_PROJECT is set to %s", projectID)
	
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	// Create a query to fetch all entities".
	query := datastore.NewQuery("Decision").Order("-added")
	keys, err := client.GetAll(ctx, query, &decs)
	if err != nil {
		fmt.Println(err)
	}

	err = client.DeleteMulti(ctx, keys)
	if err != nil {
                fmt.Println(err)
        }

}
