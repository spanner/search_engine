fs = require 'fs'
stop_words = ["i", "a", "about", "an", "and", "are", "as", "at", "be", "but", "by", "com", "de", "do", "en", "for", "from", "get", "has", "have", "how", "if", "in", "is", "it", "its", "la", "of", "on", "or", "so", "that", "their", "then", "they", "this", "to", "too", "was", "we", "what", "when", "where", "who", "will", "with", "the", "www"]

module = do ->
  getIndices: (directory) ->
    fs.readdir directory, (err, files) ->
      console.log "Error: #{err}" if err
      indices = {}
      files = files.filter (name) ->
        name.indexOf(".txt") != -1
      length = files.length

      files.forEach (name, i) ->
        if name
          fs.readFile "#{directory}/#{name}", 'utf8', (err, data) =>
            console.log "Error: #{err}" if err
            array = data.toLowerCase().match /[a-z0-9]+/ig
            for word in array
              if stop_words.indexOf(word) == -1
                word = ":#{word}"
                indices[word] ||= []
                indices[word].push name
            checkEnd()

        checkEnd = ->
          if length == i + 1
            # json
            fs.writeFile "indices.json", JSON.stringify indices

            # csv
            for word, value of indices
              if indices_csv
                indices_csv = "#{indices_csv}\n#{word},#{value}"
              else
                indices_csv = "#{word},#{value}"
            fs.writeFile "indices.csv", indices_csv, (err) ->
              console.log "Error: #{err}" if err

exports.getIndices = module.getIndices

###

index = require "./index"
index.getIndices "./documents/conquest_of_happiness"

###