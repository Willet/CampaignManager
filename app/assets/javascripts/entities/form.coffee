define [
  "entities/base"
], (Base) ->

  Entities = Entities || {}

  validators = {
    emailVal : (model) ->
      '''Rules:
            Email has only one @
            Part before @ is of length 2-50
            Part before @ has only Alphanumerics, hypens, and periods
            Part before @ has no consecutive periods or periods at beginning or end
            Part after @ has exactly one period
            Part after @ but before . is of length 2-90
            Part after @ but before . is only Alphanumbers and hyphens
            Part after @ but before . has no hypens at start or end
            Part after . is only 2 - 4 characters of alpha chars
      '''
      regex = /^([^@]*)@([^@]*)$/
      if not m = model.get('value').match(regex) then return "Err: Email must have exactly one @"
      local = m[1]
      rest = m[2]

      if local.length < 2 or local.length > 50 then return "Err: Part before @ of email must be between 2 and 50 characters long"

      regex = /^[a-zA-Z0-9\.-]*$/
      if not local.match(regex) then return "Err: Part before @ of email can only include letters, digits, periods, and hypens (-)"

      regex = /^((\..*)|(.*\.)|(.*\.\..*))$/
      if local.match(regex) then return "Err: Part before @ of email can not start or end with a period or contain two consecutive periods"

      regex = /^([^\.]*)\.([^\.]*)$/
      if not m = rest.match(regex) then return "Err: Part after @ must have exactly one period"
      domain = m[1]
      tld = m[2]

      if domain.length < 2 or domain.length > 90 then return "Err: Part from @ to '.' must be between 2 and 90 characters long"

      regex = /^[a-zA-Z0-9-]*$/
      if not domain.match(regex) then return "Err: Part from @ to '.' can only include letters, digits, or hypens (-)"

      if domain[0] is "-" or domain[-1] is "-" then return "Err: Part from @ to '.' can not start or end with a hypen (-)"

      regex = /^[a-zA-Z]{2,4}$/
      if not tld.match(regex) then return "Err: Part after '.' must consist of 2-4 letters"

      true

    urlVal : (model) ->
      '''For simplicity I am going to ignore anything after a '?' symbol or '#'
        The preceeding part is judged valid if it:
      - Starts with 'http' or 'https'
      - Followed by '://'
      - after which there are one or two text chunks (seperated by a period)
        - text chunks are made up of alphanumerics only
      - followed by periond and a short text-only chunk thats 2-4 characters (ex: com, info)
        - Url may end here, optionally with a single /
      - If not, there is a sequence of '/TEXT' chunks
        - TEXT consists of alphanumerics, underscores, or hypens
      - Url can optionally end with a file name extension or a single /
        name is made up of 2 - 10 alphanumerics'''

      regex = /^([^#\?]*)((#|\?).*)?$/
      m = model.get('value').match(regex)
      basicUrl = m[1]

      regex = /^((http)|(https)):\/\/(.*)/
      if not m = basicUrl.match(regex)
        return "Err: Url must start with 'http' or 'https' followed by '://'"
      rest = m[4]

      regex = /^(([^\.\/]+)\.)?([^\.\/]+)\.([^\.\/]+)((\/|$).*)/
      if not m = rest.match(regex)
        return "Err: '://' must be followed by 2-3 chunks of text seperated by periods and, if the url does not end, ending with a '/'"
      optFirstChunk = m[2]
      secondChunk = m[3]
      thirdChunk = m[4]
      rest = m[5]

      regex = /^[a-zA-Z0-9_-]+$/
      if (optFirstChunk? and not optFirstChunk.match(regex)) or not secondChunk.match(regex)
        return "Err: Domain name (after :// and before extension such as '.com') may only consist of letters, digits, underscores, or hypens (-) and be optionally partitioned by one period"

      regex = /^[a-zA-Z]{2,4}$/
      if not thirdChunk.match(regex)
        return "Err: Domain extension (ex: .com) must consist of 2-4 letters"

      if not rest? or rest is "" or rest is "/"
        #Valid end for url
        return true

      regex = /^(\/[\w-]+)+((\..*)|\/)?$/
      if not m = rest.match(regex)
        return "Err: Domain directories must only consits of letters, digits, undersores, and hypens"

      rest = m[2]
      if not rest? or rest is "" or rest is "/"
        #Valid end for url
        return true

      regex = /^\.[a-zA-Z0-9]{2,10}$/
      if not rest.match(regex)
        return "Err: Filename extensions must consist of 2-10 letters, or digits"
      true
  }

  class Entities.FormElem extends Base.Model

    defaults:
      value: null

    validate: ->
      #Calls validate fuction, whose name is stored as a string, on some data
      #The function either returns True or Error messages
      validatorName = @get("validator")
      if not validatorName? then return "Err: No validator specified"
      console.log(validatorName)
      valFun = validators[validatorName]
      if not valFun?
        return "Err: Invalid validator name: " + validatorName

      return valFun(@)

  class Entities.FormElemCollection extends Base.Collection
    model: Entities.FormElem

    validate: ->
      errors = []
      for m in @models
        r = m.validate()
        if r isnt true
          errors.push([m,r])
      if errors.length == 0
        return true
      else
        return errors

    getConfigJSON: ->
      jsonObj = {}
      for m in @models
        jsonObj[m.get('var')] = m.get('value')
      return jsonObj

  Entities