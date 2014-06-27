---
---

class RepositoryView extends Backbone.View
    initialize: (options) ->
        @owner = options.owner
        @repository = options.repository
        @fetchRepository()
    fetchRepository: ->
        $.getJSON(
            'https://api.github.com/repos/'+@owner+'/'+@repository,
            (data) =>
                @render(data)
        );

    render: (repository) ->
        @renderTitle(repository.name)
        @renderDescription(repository.description)
        @renderLanguage(repository.language)

    renderTitle: (title) ->
        $('.repo-title',@el).text(title)
    renderDescription: (description) ->
        $('.repo-desc',@el).text(description)
    renderLanguage: (language) ->
        $('.repo-lang',@el).text(language)
$(->
    $('.repository').each ->
        new RepositoryView
            el: $(this)
            owner: $(this).data('user')
            repository: $(this).data('repo')
)()
