package main

import (
    "fmt"
    "io/ioutil"
    "strings"
    "strconv"
    "regexp"
    "net/http"
    "context"
    "time"
    "os"
    "log"

    "cloud.google.com/go/datastore"
)

type Decision struct {
	Added   time.Time `datastore:"added"`
	Link    string    `datastore:"link"`
	Name    string     // The ID used in the datastore.
}

func PutDecs(links []string) {

	projectID := os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}

	var decs []Decision
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	defer client.Close()
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	keys := []*datastore.Key{datastore.NameKey("Id", "Decision", nil)}

	for i:=0; i<len(links); i++ {
//		keys[i] = datastore.NewIncompleteKey(ctx, "Decision", nil)
//		keys[i] = datastore.Namekey("Id", strconv.Itoa(i), nil)
		decs[i].Added = time.Now()
		decs[i].Link  = links[i]
	}

	_, err2 := client.PutMulti(ctx,  keys, &decs)
	if err2 != nil {
		log.Fatal(err2)
	}
}


func parsePage(page_link string) []string {
	response, err := http.Get(page_link)
	match_sli := make([]string, 10)
	if err != nil {
           fmt.Println(err)
        }

	defer response.Body.Close()
	body,err := ioutil.ReadAll(response.Body)
        bodyString := string(body)
	re, _ := regexp.Compile("https://github.com/[a-z0-9A-Z-]+/[a-z0-9A-Z-]+&quot;")
	match := re.FindAllStringSubmatchIndex(bodyString,-1)

	for i:=0; i<len(match); i++ {
		separate_link_temp:=bodyString[match[i][0]:match[i][1]]
		separate_link:=strings.ReplaceAll(separate_link_temp, "&quot;", "")
		match_sli=append(match_sli,separate_link)
	}

	return match_sli
}


func main() {
	URL:="https://github.com/search?q=gcp+datastore"
	p1URL:="https://github.com/search?p="
	p2URL:="&q=gcp+datastore&type=Repositories"
	var number_of_pages int
	var all_links_sli_temp []string
	var all_links_sli []string


	response, err := http.Get(URL)
	if err != nil {
           fmt.Println(err)
           return
        }

	defer response.Body.Close()

	body,err := ioutil.ReadAll(response.Body)
	bodyString := string(body)
//	fmt.Println(bodyString)
	if strings.ContainsAny(bodyString, "<a class=\"next_page\"") {
		re, _ := regexp.Compile(">[0-9]+</a> <a class=\"next_page\"")
		match := re.FindString(bodyString)
		temp_str := strings.ReplaceAll(match, "</a> <a class=\"next_page\"", "")
		temp_str2 := strings.ReplaceAll(temp_str, ">", "")
		number_of_pages, err = strconv.Atoi(temp_str2)
	        if err != nil {
        	   fmt.Println(err)
	           return
	        }
//		fmt.Println(number_of_pages)
	} else {
		fmt.Println("This URL is not parsable")
	}

//Iterator accross pages
	for i:=1; i<=number_of_pages; i++ {
		specific_URL := p1URL + strconv.Itoa(i) + p2URL
//		fmt.Println(specific_URL)
		extracted_direct_link := parsePage(specific_URL)
		for j:=0; j<len(extracted_direct_link); j++ {
		    all_links_sli_temp = append(all_links_sli_temp, extracted_direct_link[j])
		}
//		fmt.Println(extracted_direct_link)
	}

	for _, element := range all_links_sli_temp {
		if element != "" {
			all_links_sli = append(all_links_sli, element)
		}
	}

	for _, element := range all_links_sli {
		fmt.Println(element)
	}

	PutDecs(all_links_sli)
}
