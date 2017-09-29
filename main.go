package main

import (
	"flag"
	"fmt"
	"os/exec"
	log "github.com/liuzheng712/golog"
)

func main() {
	flag.Parse()
	LoadConfig()
	Commands := []string{}
	for k, v := range Config.Configure {
		if v == "" {
			Commands = append(Commands, k)
		} else {
			Commands = append(Commands, fmt.Sprintf("%v=%v", k, v))
		}
	}
	cmd := exec.Command("./configure", Commands...)
	if err := cmd.Start(); err != nil {
		log.Fatal("Run", "%v", err)
	}
}
