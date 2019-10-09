package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	serverUri := "{oc-examples-server-url}/ocs/v1.php/apps/files_sharing/api/v1"
	username := "admin"
	passwd := "admin"

	client := &http.Client{}

	req, err := http.NewRequest("DELETE", fmt.Sprintf("%s/%s", serverUri, "shares/pending/<share_id>"), nil)
	if err != nil {
		log.Print(err)
		os.Exit(1)
	}

	req.SetBasicAuth(username, passwd)

	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}

	bodyText, err := ioutil.ReadAll(resp.Body)
	fmt.Println(string(bodyText))
}
