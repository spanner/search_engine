fs = require 'fs'
BM = require 'benchmark'

fs.readFile "indices.json", "utf8", (err, data) ->
  console.log "Error: #{err}" if err
  json_data = JSON.parse(data)
  fs.readFile "indices.csv", "utf8", (err, data) ->
    console.log "Error: #{err}" if err
    csv_data = data
    
    suite = new BM.Suite
    suite.add "searchCSV", ->
      searchCSV "thought"
    .add "searchJSON", ->
      searchJSON "thought"
    .on 'cycle', (event) ->
      console.log String(event.target)
    .on 'complete', () ->
      console.log 'Fastest is ' + this.filter('fastest').pluck('name')
    .run
      'async': true


# module = do =>
searchCSV: (term) ->
  # console.log "not yet searching", data
    
searchJSON: (term) ->
  term = ":#{term}"
  json_data[term]
  # console.log indices[term]


exports.searchCSV = module.searchCSV
exports.searchJSON = module.searchJSON

###

search = require "./search"
search.searchJSON ""
search.searchCSV ""

###

