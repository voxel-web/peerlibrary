Deps.autorun ->
  return unless Meteor.settings?.public?.examples

  if Session.get 'indexActive'
    Meteor.subscribe 'publication-by-id', Random.choice Meteor.settings.public.examples

Template.header.events =
  'click .top-menu .search': (event, template) ->
    # Only if focused on no-index header
    if Template.header.noIndexHeader()
      Session.set 'searchFocused', true

    return # Make sure CoffeeScript does not return anything

  'click .search-input': (event, template) ->
    # Only if focused on no-index header
    if Template.header.noIndexHeader()
      Session.set 'searchFocused', true

    return # Make sure CoffeeScript does not return anything

  'click .search-button': (event, template) ->
    Session.set 'searchActive', true
    generalQueryChange $(template.findAll '.search-input').val()

    return # Make sure CoffeeScript does not return anything

  'blur .search-input': (event, template) ->
    Session.set 'searchFocused', false
    generalQueryChange $(template.findAll '.search-input').val()

    return # Make sure CoffeeScript does not return anything

  'change .search-input': (event, template) ->
    Session.set 'searchActive', true
    Session.set 'searchFocused', true
    generalQueryChange $(template.findAll '.search-input').val()

    return # Make sure CoffeeScript does not return anything

  'keyup .search-input': (event, template) ->
    val = $(template.findAll '.search-input').val()

    # If user focused with tab or pressed some other non-content key we don't want to activate the search
    if val
      Session.set 'searchActive', true
      Session.set 'searchFocused', true

    generalQueryChange val

    return # Make sure CoffeeScript does not return anything

  'paste .search-input': (event, template) ->
    Session.set 'searchActive', true
    Session.set 'searchFocused', true
    generalQueryChange $(template.findAll '.search-input').val()

    return # Make sure CoffeeScript does not return anything

  'cut .search-input': (event, template) ->
    Session.set 'searchActive', true
    Session.set 'searchFocused', true
    generalQueryChange $(template.findAll '.search-input').val()

    return # Make sure CoffeeScript does not return anything

  'submit #search': (event, template) ->
    event.preventDefault()
    # If search is empty and user presses enter (submits the form), we should activate - maybe user wants structured query form
    Session.set 'searchActive', true
    Session.set 'searchFocused', true
    generalQueryChange $(template.findAll '.search-input').val()

    return # Make sure CoffeeScript does not return anything

Template.header.development = ->
  'development' unless Meteor.settings?.public?.production

Template.header.indexHeader = ->
  'index-header' if Template.footer.indexFooter()

Template.header.noIndexHeader = ->
  'no-index-header' if not Template.header.indexHeader()

Template.searchInput.searchFocused = ->
  'search-focused' if Session.get 'searchFocused'

Template.searchInput.created = ->
  @_searchQueryHandle = null

Template.searchInput.rendered = ->
  # We make sure search input is focused if we know it should be focused (to make sure focus is
  # retained between redraws). We don't use HTML5 autofocus because it takes focus away from dialogs.
  # We focus search if we are displaying index header. Don't try to focus if reset password or enroll
  # user is in progress.
  if (Session.get('searchFocused') or Template.header.indexHeader()) and not Accounts._loginButtonsSession.get('resetPasswordToken') and not Accounts._loginButtonsSession.get 'enrollAccountToken'
    $(@findAll '.search-input').focus()

  @_searchQueryHandle?.stop()
  @_searchQueryHandle = Deps.autorun =>
    # Sync input field unless change happened because of this input field itself
    $(@findAll '.search-input').val(Session.get 'currentSearchQuery') unless generalQueryChangeLock > 0

Template.searchInput.destroyed = ->
  @_searchQueryHandle?.stop()
  @_searchQueryHandle = null

Template.searchInput.indexHeader = Template.header.indexHeader

Template.searchInput.noIndexHeader = Template.header.noIndexHeader

Template.searchInput.searchInvitation = ->
  if Session.get 'currentSearchQuery'
    Session.get 'currentSearchQuery'
  else
    "Search academic publications and people"

Template.searchInput.development = Template.header.development

Template.searchInput.examplePublication = ->
  return unless Meteor.settings?.public?.examples

  Publication.documents.findOne
    _id:
      $in: Meteor.settings.public.examples
  ,
    fields:
      _id: 1
      slug: 1

Template.progressBar.progress = ->
  100 * Session.get 'currentPublicationProgress'

progressHide = null
Deps.autorun ->
  progress = Session.get 'currentPublicationProgress'

  if progress != 1.0
    Meteor.clearTimeout progressHide if progressHide
    progressHide = null
    return

  return if progressHide

  progressHide = Meteor.setTimeout ->
    Session.set 'currentPublicationProgress', null
    progressHide = null
  , 250 # ms

Accounts.ui.config
  passwordSignupFields: 'USERNAME_AND_EMAIL'
