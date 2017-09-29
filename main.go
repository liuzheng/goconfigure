package main

import (
	"flag"
	"fmt"
	"os/exec"
	log "github.com/liuzheng712/golog"
	"os"
	"strings"
	"syscall"
	"os/signal"
)

func main() {
	flag.Parse()
	LoadConfig()
	Commands := []string{}
	for k, v := range Config.Configure {
		if v == "" || v == nil {
			Commands = append(Commands, k)
		} else {
			Commands = append(Commands, fmt.Sprintf("%v=%v", k, v))
		}
	}
	cmd := exec.Command("./configure", Commands...)
	fmt.Println(strings.Join(cmd.Args, " "))
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	//cmd.SysProcAttr = &syscall.SysProcAttr{
	//	Setpgid: true,
	//}

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)

	if err := cmd.Start(); err != nil {
		log.Fatal("Run", "%v", err)
	}
	go func() {
		cmd.Wait()
		os.Exit(0)
	}()
FOR:
	for {
		select {
		case <-signals:
			pro, _ := os.FindProcess(cmd.Process.Pid)
			pro.Kill()
			os.Exit(0)
			break FOR
		}
	}
}
