#!/bin/bash

cp ../lib/{function.rb,function_group.rb,orchestrator.rb,modifier.rb} pipe-test/.
faas build -f pipe-test.yml
faas-cli deploy -f ./pipe-test.yml
