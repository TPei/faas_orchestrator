# FaaS Orchestrator

Building orchestration functions easy as 1, 2, 3

[![Build Status](https://travis-ci.org/TPei/faas_orchestrator.svg?branch=master)](https://travis-ci.org/TPei/faas_orchestrator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenFaaS](https://img.shields.io/badge/openfaas-serverless-blue.svg)](https://www.openfaas.com)

## What is this?

FaaSOrchestrator allows you to easily buid Orchestration Functions for
OpenFaaS. Imagine wanting to just call two functions, pipeline style:

```ruby
Orchestrator.new.
  first('get_weather_data').
  finally('post_to_slack')
```

This code will call the first function, then call the second function
with output from the first and then return the result of the second
function.

### Orchestration?
Well, if you want to have multiple functions work together and not
couple them incredibly tightly (by calling B directly from A), you will
want a manager function (orchestrator) that calls the functions for you
:)

### So what...
Now there's a bunch of stuff we have to consider here... configuration,
retries, maybe something like calling multiple functions in parallel...
Suddenly, you have to write a bunch of code! :(
But FaaS Orchestrator alleviates this pain and allows for easily
building complex orchestrations!

For example, you might need to modify data in between functions:

```ruby
Orchestrator.new.
  first('get_weather_data').
  modify do |data|
    data = JSON.parse(data)
    { current_temp: data['Berlin']['now']['celsius'] }
  end.
  finally('post_to_slack')
```

You can easily use modify blocks for that. The result will be passed on,
the rest thrown out! :tada:

You can also fan out and have multiple functions run on the same data,
combining the result!


```ruby
Orchestrator.new.
  first('fetch_performance_analysis').
  then(multiple: [['calc_avg'], ['calc_median']]).
  modify do |data|
    "Current Server performance:\n"\
    "- average response time #{data[0]} \n"\
    "- median response time #{data[1]}."
  end.
  finally(multiple: [['update_status_page'], ['post_to_slack']])
```

### What if I want to keep old data when fanning out?
No problem! Use `Orchestrator::RETAIN` to move data along:

```ruby
Orchestrator.new.
  first('get_weather_data').
  then(multiple: [['make_prediction'], [Orchestrator::RETAIN]]).
  modify do |data|
    {
      current_temp: data[1]['current']['celsius'],
      prediction: data[0]['future']['celsius']
    }
  end.
  finally('post_to_slack')
```

## Ok, you got me, how do I use this?
TODO
