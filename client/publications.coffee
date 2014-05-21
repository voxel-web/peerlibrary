Catalog.create 'publications', Publication,
  main: Template.publications
  empty: Template.noPublications
  loading: Template.publicationsLoading
,
  active: 'publicationsActive'
  ready: 'currentPublicationsReady'
  loading: 'currentPublicationsLoading'
  count: 'currentPublicationsCount'
  filter: 'currentPublicationsFilter'
  limit: 'currentPublicationsLimit'
  sort: 'currentPublicationsSort'

Deps.autorun ->
  if Session.equals 'publicationsActive', true
    Meteor.subscribe 'my-publications'

Template.publications.catalogSettings = ->
  settings =
    entityClass: Publication
    variables:
      filter: 'currentPublicationsFilter'
      sort: 'currentPublicationsSort'

  settings
