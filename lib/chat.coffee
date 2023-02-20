@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    if Meteor.userId()
        doc._author_id = Meteor.userId()
        doc._author_username = Meteor.user().username
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    # doc.app = 'nf'
    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return



if Meteor.isClient 
    $.cloudinary.config
        cloud_name:"facet"
    
    Template.registerHelper '_when', () -> moment(@_timestamp).fromNow()
    Template.registerHelper '_author', () -> Meteor.users.findOne @_author_id

    Template.home.onCreated ->
        @autorun => @subscribe 'chat', ->
        @autorun => @subscribe 'users', ->
            
    Template.message_item.events
        'click .vote_up': ->
            Meteor.call 'upvote',@_id,->
            # Docs.update @_id,
            #     $inc:
            #         points:1
            #     $addToSet:
            #         upvoter_ids:Meteor.userId()
        'click .vote_down': ->
            Meteor.call 'downvote',@_id,->
            # Docs.update @_id,
            #     $inc:
            #         points:-1
            #     $addToSet:
            #         downvoter_ids:Meteor.userId()
                    
    Template.home.events
        'hover .tada': (e,t)-> $(e.currentTarget).closest('.tada').transition('pulse', 500)
        'click .fly_right': (e,t)-> $(e.currentTarget).closest('.grid').transition('fade right', 500)
        'click .zoom': (e,t)-> $(e.currentTarget).closest('.grid').transition('drop', 500)
        'click .fade_left': (e,t)-> 
            $(e.currentTarget).closest('.card').transition('fade left', 500)
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
        'click .fade_down': (e,t)-> $(e.currentTarget).closest('.grid').transition('fade down', 500)
        'click .fly_down': (e,t)-> $(e.currentTarget).closest('.grid').transition('fly down', 500)
        # 'click .button': ->
        #     $(e.currentTarget).closest('.button').transition('bounce', 1000)
    
        # 'click a(not:': ->
        #     $('.global_container')
        #     .transition('fade out', 200)
        #     .transition('fade in', 200)
    
        'click .log_view': ->
            # console.log Template.currentData()
            # console.log @
            Docs.update @_id,
                $inc: views: 1
        'click .logout': ->
            Session.set('loading',true)
            Meteor.logout(()->
                Session.set('loading',false)
                $('body').toast({message:"logged out", position:'bottom right'})
                )
        'keyup .new_message': (e)->
            if e.which is 13
                val = $('.new_message').val().trim()
                if val.length > 0
                    Docs.insert 
                        model:'message'
                        body:val
                val = $('.new_message').val('')
                $('body').toast({message:"#{val} message added", position:'bottom right'})
                
    Template.home.helpers
        is_loading: -> Session.get('loading')
        message_docs: ->
            Docs.find 
                model:'message'
    Template.message_item.helpers
        upvote_class: ->
            if @upvoter_ids and Meteor.userId() in @upvoter_ids
                'green large'
            else 
                'outline'
        downvote_class: ->
            if @downvoter_ids and Meteor.userId() in @downvoter_ids
                'red large'
            else 
                'outline'
    
if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret
    
    Docs.allow
        insert: (userId, doc) -> 
            true    
            # doc._author_id is userId
        update: (userId, doc) ->
            true
            # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
            #     true
            # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
            #     true
            # else
            #     doc._author_id is userId
        # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
        remove: (userId, doc) -> 
            true
            # doc._author_id is userId or 'admin' in Meteor.user().roles
    
    Meteor.publish 'chat', ->
        Docs.find 
            model:'message'
            
    Meteor.publish 'users', ->
        Meteor.users.find {},
            fields:
                username:1
                image_id:1
                tags:1
            
            
            
            