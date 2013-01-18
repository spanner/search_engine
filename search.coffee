fs = require 'fs'
BM = require 'benchmark'
csv = require 'csv'

getCSV = =>
  fs.readFile "./indices/indices.csv", "utf8", (err, data) =>
    console.log "Error: #{err}" if err
    @csv_indices = data

getJSON = =>
  fs.readFile "./indices/indices.json", "utf8", (err, data) =>
    console.log "Error: #{err}" if err
    @json_indices = data

getReferences = =>
  fs.readFile "files.json", "utf8", (err, data) =>
    @references = JSON.parse data

buildBenchmarks = =>
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
  term = symbolise term
  indices = {}
  csv().from(@csv_indices, {columns: true}).transform (line) =>
    word = line["word"]
    delete line["word"]
    indices[word] = line
  .on "end", (count) =>
    results = []
    for key, value of indices[term]
      results.push {doc_id: parseInt(key, 10), count: parseInt(value, 10)} if value > 0
    report results
  null

searchJSON = (term) =>
  term = symbolise term
  indices = JSON.parse @json_indices
  results = []
  for key, value of indices[term]
    results.push {doc_id: parseInt(key, 10), count: value}
  report results
  null

runBenchmarks = =>
  @suite.run
    'async': true

sortByCount = (results) =>
  results.sort (a,b) =>
    b.count - a.count

report = (results) =>
  sorted_results = sortByCount results
  filtered_result = @references.filter (doc) =>
    doc.id == sorted_results[0].doc_id
  top_result = filtered_result[0]
  console.log "Top Result =>", top_result.name
  console.log sorted_results

symbolise = (string) =>
  ":#{string}"

setUp = =>
  getCSV()
  getJSON()
  getReferences()
  buildBenchmarks()

setUp()

# command line links
exports.searchCSV = searchCSV
exports.searchJSON = searchJSON
exports.runBenchmarks = runBenchmarks
exports.setUp = setUp

### coffee commands

search = require "./search"
search.runBenchmarks()

search.searchJSON "thought"
search.searchCSV "thought"

###

