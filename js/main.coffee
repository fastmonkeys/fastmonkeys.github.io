---
---



class Repository extends Backbone.Model
    initialize: ->

class Owner extends Backbone.Model
    attributes: ->
        repos: null

    url: ->
        'https://api.github.com/users/'+@get('name')

    populateRepos: ->
        $.getJSON(
            'https://api.github.com/users/'+@get('name')+'/repos?per_page=100',
            (data) =>
                RepoCollection = Backbone.Collection.extend({
                    model: Repository
                });
                @set(
                    repos: new RepoCollection(data)
                )
        );
        return

class ApplicationView extends Backbone.View
    initialize: (options) ->
        @templates = options.templates
        @initializeModels()


    initializeModels: ->
        OwnerCollection = Backbone.Collection.extend({
            model: Owner
        });

        @owners = new OwnerCollection(
            ($('.owner').map (i, elem) =>
                owner = new Owner
                    name: $(elem).data('owner')
                owner.fetch()
                owner.once('change:repos', @_initializeOwnerViews )
            ).get()
        )
        @owners.each (owner) ->
            owner.populateRepos()

    _initializeOwnerViews: (owner, repos) =>
        ownername = owner.get('login')
        new OwnerView
            el: $('.owner[data-owner=' + ownername + ']')
            model: owner
            collection: repos
            templates: @templates

class OwnerView extends Backbone.View
    initialize: (options) ->
        @templates = options.templates
        @_initializeRepositoryViews()


    _initializeRepositoryViews: ->
        jQueryRepos = @$('.repository')
        jQueryRepos.each (i, elem) =>
            reponame = $(elem).data('repo')
            repo = @collection.findWhere({name:reponame})
            if repo
                new RepositoryView(
                    model: repo
                    el:elem
                    template: @templates.repository
                )


class RepositoryView extends Backbone.View
    initialize: (options) ->
        @template = options.template
        @render()

    render: () ->
        $(@el).html Mustache.render(@template, @model.toJSON())

$( ->
    window.templates = {
        repository: $('#repo-template').html()
    }
    _(templates).each (template) ->
        Mustache.parse(template)
    applicationView = new ApplicationView(
        templates: templates
    )
)
