fs = require 'fs'
stop_words = ["i", "a", "about", "an", "and", "are", "as", "at", "be", "but", "by", "com", "de", "do", "en", "for", "from", "get", "has", "have", "how", "if", "in", "is", "it", "its", "la", "of", "on", "or", "so", "that", "their", "then", "they", "this", "to", "too", "was", "we", "what", "when", "where", "who", "will", "with", "the", "www"]

indexDocuments = (directory) ->
  fs.readdir directory, (err, files) ->
    console.log "Error: #{err}" if err
    indices = {}
    file_names = files.filter (name) ->
      name.indexOf(".txt") != -1
    files = []
    file_names.forEach (name, i) ->
      files.push {name: name, id: i + 1}
    fs.writeFile "files.json", JSON.stringify files
    length = files.length
    
    files.forEach (file, i) ->
      fs.readFile "#{directory}/#{file.name}", 'utf8', (err, data) =>
        console.log "Error: #{err}" if err
        title = data.toLowerCase().match( /^(.*)$/m )[0].match /[a-z0-9]+/ig
        data = data.replace( /^(.*)$/m, "" )
        text = data.toLowerCase().match /[a-z0-9]+/ig
        indexOccurences = (source, weight) =>
          weight ||= 1
          for word in source
            if stop_words.indexOf(word) == -1
              symbol = ":#{word}"
              indices[symbol] ||= {}
              index = indices[symbol]
              if index[file.id]
                index[file.id] += weight
              else
                index[file.id] = weight
        indexOccurences title, 10
        indexOccurences text
        checkEnd()

      checkEnd = ->
        if length == i + 1
          console.log indices
          # json
          fs.writeFile "indices/indices.json", JSON.stringify indices

          # csv
          indices_csv = "word"
          for file in files
            indices_csv = "#{indices_csv},#{file.id}"
          for word, value of indices
            index = "\n#{word}"
            for file in files
              weight = value[file.id] || 0
              index = "#{index},#{weight}"
            indices_csv = "#{indices_csv}#{index}"
          fs.writeFile "indices/indices.csv", indices_csv, (err) ->
            console.log "Error: #{err}" if err


exports.indexDocuments = indexDocuments

### coffee commands

index = require "./index"
index.indexDocuments "./documents/conquest_of_happiness"

###

### JSON

indexing = {
  {:word1 => [document1, document2]},
  {:word2 => [document2, document3]},
  {:word3 => [document3]}
}


weighted_indexing = {
  {
    :word1 => [
      document1 => 2,
      document2 => 7
    ]
  },
  {
    :word2 => [
      document2 => 4,
      document3 => 1
    ]
  },
  {
    :word3 => [
      document3 => 2
    ]
  }
}

###

### CSV

indexing =

word1,document1,document2
word2,document2,document3
word3,document3

or

word,document1,document2,document3
word1,1,1,0
word2,0,1,1
word3,0,0,1

weighted_indexing =

word,document1,document2,document3
word1,2,7,0
word2,0,4,1
word3,0,0,2

###

### YAML

indexing =

word1: document1,document2
word2: document2,document3
word3: document3

weighted_indexing =

word1:
  document1: 2
  document2: 7
word2:
  document2: 4
  document3: 1
word3:
  document3: 2

###

