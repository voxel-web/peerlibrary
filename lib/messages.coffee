@FormError = Meteor.makeErrorType 'FormError',
  (error, reason, field) ->
    throw new Error "Error not set" unless error
    @error = error
    @reason = reason or ''
    @field = field or ''

# Session variable wrapper for info/error messages
class @FormMessages
  fields: [''] # Global field is always registered
  messageType:
    ERROR: 'errorMessage'
    INFO: 'infoMessage'

  constructor: (prefix) ->
    @prefix = prefix or "form-#{ Random.id() }-"

  _set: (messageType, field, value) =>
    field = '' unless field
    Session.set @prefix + messageType + field, value

  _get: (messageType, field) =>
    field = '' unless field
    throw new Error "Field #{ field } does not exist" unless field in @fields
    Session.get @prefix + messageType + field

  _registerField: (field) =>
    @fields.push field unless field in @fields

  # Returns object containing both info and error messages
  get: (field) =>
    return {} =
      errorMessage: @getErrorMessage field
      infoMessage: @getInfoMessage field

  # Resets both info and error messages
  resetMessages: (field) =>
    if !field and field isnt ''
      fields = @fields
    else
      fields = [field]
    for field in fields
      @_set @messageType.INFO, field, ''
      @_set @messageType.ERROR, field, ''

  setError: (error) =>
    @setErrorMessage error.reason, error.field

  # Sets error message for given field or global error message if field is not set
  setErrorMessage: (message, field) =>
    @_registerField field if field
    @_set @messageType.INFO, field, ''
    @_set @messageType.ERROR, field, message

  # Sets info message for given field or global info message if field is not set
  setInfoMessage: (message, field) =>
    @_registerField field if field
    @_set @messageType.ERROR, field, ''
    @_set @messageType.INFO, field, message

  # Gets error message for given field or global error message if field is not set
  getErrorMessage: (field) =>
    @_registerField field if field
    @_get @messageType.ERROR, field

  # Gets info message for given field or global info message if filed is not set
  getInfoMessage: (field) =>
    @_registerField field if field
    @_get @messageType.INFO, field

