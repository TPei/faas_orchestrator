#!/bin/bash

cp ../lib/{function.rb,get_function.rb,post_function.rb,retainer_function.rb,function_group.rb,orchestrator.rb,modifier.rb,orchestrator_creator.rb} pipe-test/.
faas build -f pipe-test.yml
faas-cli deploy -f ./pipe-test.yml
