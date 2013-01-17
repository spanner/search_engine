fs = require 'fs'
BM = require 'benchmark'
csv = require 'csv'

getCSV = =>
  fs.readFile "./indices.csv", "utf8", (err, data) =>
    console.log "Error: #{err}" if err
    @csv_indices = data

getJSON = =>
  fs.readFile "./indices.json", "utf8", (err, data) =>
    console.log "Error: #{err}" if err
    @json_indices = data

buildBenchmark = =>
  @suite = new BM.Suite
  @suite.add "searchCSV", ->
    searchCSV "thought"
  .add "searchJSON", ->
    searchJSON "thought"
  .on 'cycle', (event) ->
    console.log String(event.target)
  .on 'complete', () ->
    console.log 'Fastest is ' + this.filter('fastest').pluck('name')

searchCSV = (term) =>
  term = ":#{term}"
  indices = {}
  csv().from(@csv_indices).transform (line) =>
    word = line.splice(0, 1)[0]
    indices[word] = line
  .on "end", (count) =>
    console.log indices[term]

searchJSON = (term) =>
  term = ":#{term}"
  indices = JSON.parse @json_indices
  indices[term]

runBenchmark = =>
  @suite.run
    'async': true

setUp = =>
  getCSV()
  getJSON()
  buildBenchmark()

setUp()



exports.searchCSV = searchCSV
exports.searchJSON = searchJSON
exports.runBenchmark = runBenchmark
exports.setUp = setUp

###

search = require "./search"
search.runBenchmark()

search.searchJSON "thought"
search.searchCSV "thought"

###

