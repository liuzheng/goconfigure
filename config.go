package main

import (
	yaml "gopkg.in/yaml.v2"
	"flag"
	"path/filepath"
	"io/ioutil"
	log "github.com/liuzheng712/golog"
)

var (
	config = flag.String("c", "configure.yml", "the configure.yml")
)

type Configer struct {
	Yaml      []byte
	Configure map[string]interface{} `yaml:"configure"`
}

var Config *Configer = &Configer{}

func LoadConfig() {
	filename, err := filepath.Abs(*config)
	if err != nil {
		log.Error("LoadConfig", "%v", err)
	} else {
		Config.Yaml, err = ioutil.ReadFile(filename)
		if err != nil {
			log.Error("LoadConfig", "%v", err)
			log.Error("LoadConfig", "try to use command `./configure`")
		} else {
			err = yaml.Unmarshal(Config.Yaml, &Config)
			if err != nil {
				log.Error("LoadConfig", "%v", err)
				panic(err)
			}
		}
	}
}
