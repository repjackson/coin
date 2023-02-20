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
            
            
            
            
            
# if Meteor.isClient
#     Template.registerHelper 'transfer_products', () -> 
#         Docs.find
#             model:'product'
#             transfer_id:@_id
#     Template.registerHelper 'product_transfer', () -> 
#         found = 
#             Docs.findOne
#                 model:'transfer'
#                 _id:@transfer_id
#         # console.log found
#         found
    
#     Template.user_credit.onCreated ->
#         @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
#         @autorun -> Meteor.subscribe 'deposits', Router.current().params.username, ->
    
#     Template.user_credit.events 
#         'click .calc_points': ->
#             Meteor.call 'calc_user_points', Meteor.userId(), ->
                
                
            
#     Template.user_credit.helpers
#         # read_docs: ->
#         #     user = Meteor.users.findOne username:Router.current().params.username 
#         #     Docs.find 
#         #         read_by_user_ids: $in: [user._id]
    
#     Template.user_credit.onCreated ->
#         @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username, ->
#         @autorun => Meteor.subscribe 'model_docs', 'deposit', ->
#         # @autorun => Meteor.subscribe 'model_docs', 'reservation'
#         # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
#         # @autorun => Meteor.subscribe 'my_topups'
#         pub_key = Meteor.settings.public.stripe_test_publishable
#         # if Meteor.isDevelopment
#         #     pub_key = Meteor.settings.public.stripe_test_publishable
#         # else if Meteor.isProduction
#         #     pub_key = Meteor.settings.public.stripe_live_publishable
#     #     Template.instance().checkout = StripeCheckout.configure(
#     #         key: pub_key
#     #         image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
#     #         locale: 'auto'
#     #         # zipCode: true
#     #         token: (token) ->
#     #             # product = Docs.findOne Router.current().params.doc_id
#     #             user = Meteor.users.findOne username:Router.current().params.username
#     #             deposit_amount = parseInt $('.deposit_amount').val()*100
#     #             stripe_charge = deposit_amount*100*1.02+20
#     #             # calculated_amount = deposit_amount*100
#     #             # console.log calculated_amount
#     #             charge =
#     #                 amount: deposit_amount*1.02+20
#     #                 currency: 'usd'
#     #                 source: token.id
#     #                 description: token.description
#     #                 # receipt_email: token.email
#     #             Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
#     #                 if error then alert error.reason, 'danger'
#     #                 else
#     #                     alert 'payment received', 'success'
#     #                     Docs.insert
#     #                         model:'deposit'
#     #                         deposit_amount:deposit_amount/100
#     #                         stripe_charge:stripe_charge
#     #                         amount_with_bonus:deposit_amount*1.05/100
#     #                         bonus:deposit_amount*.05/100
#     #                     Meteor.users.update user._id,
#     #                         $inc: credit: deposit_amount*1.05/100
#     # 	)


#     Template.user_credit.events
#         'click .add_credits': ->
#             note = prompt 'note'
#             note = if note then note else ''
#             amount = parseInt $('.deposit_amount').val()
#             amount_times_100 = parseInt amount*100
#             calculated_amount = amount_times_100*1.02+20
#             Template.instance().checkout.open
#                 name: 'credit deposit'
#                 # email:Meteor.user().emails[0].address
#                 description: "gratigen fiat deposit #{note}"
#                 amount: calculated_amount
#             Docs.insert
#                 model:'deposit'
#                 amount: amount
#             Meteor.users.update Meteor.userId(),
#                 $inc: credit: amount_times_100


#     Template.user_credit.events
#         'click .initial_withdrawal': ->
#             withdrawal_amount = parseInt $('.withdrawal_amount').val()
#             if confirm "initiate withdrawal for #{withdrawal_amount}?"
#                 Docs.insert
#                     model:'withdrawal'
#                     amount: withdrawal_amount
#                     status: 'started'
#                     complete: false
#                 Meteor.users.update Meteor.userId(),
#                     $inc: credit: -withdrawal_amount

#         'click .cancel_withdrawal': ->
#             if confirm "cancel withdrawal for #{@amount}?"
#                 Docs.remove @_id
#                 Meteor.users.update Meteor.userId(),
#                     $inc: credit: @amount

#         'click .send_points': ->
#             new_id = 
#                 Docs.insert 
#                     model:'transfer'
#                     amount:10
#             Router.go "/transfer/#{new_id}/edit"


#     Template.user_credit.helpers
#         payments: ->
#             Docs.find {
#                 model:'payment'
#                 _author_username: Router.current().params.username
#             }, sort:_timestamp:-1
#         user_deposits: ->
#             Docs.find {
#                 model:'deposit'
#                 _author_username: Router.current().params.username
#             }, sort:_timestamp:-1
#         topups: ->
#             Docs.find {
#                 model:'topup'
#                 _author_username: Router.current().params.username
#             }, sort:_timestamp:-1



#     Template.user_credit.events
#         'click .add_credit': ->
#             user = Meteor.users.findOne(username:Router.current().params.username)
#             Meteor.users.update Meteor.userId(),
#                 $inc:points:10
#                 # $set:points:1
#         'click .remove_points': ->
#             user = Meteor.users.findOne(username:Router.current().params.username)
#             Meteor.users.update Meteor.userId(),
#                 $inc:points:-1
#     Template.buy_coin.events
#         'click .topup': ->
#             # deposit_amount = parseInt $('.deposit_amount').val()*100
#             deposit_amount = parseInt @amount*100
#             calculated_amount = deposit_amount*1.02+20
#             note = prompt 'note'
#             note = if note then note else ''
#             Template.instance().checkout.open
#                 name: 'credit deposit'
#                 # email:Meteor.user().emails[0].address
#                 description: note
#                 amount: calculated_amount
#             Docs.insert 
#                 model:'deposit'
#                 stripe_amount:calculated_amount
#                 amount:deposit_amount
#             $('body').toast(
#                 showIcon: 'checkmark'
#                 message: "deposit complete"
#                 # showProgress: 'bottom'
#                 class: 'success'
#                 # displayTime: 'auto',
#                 position: "bottom right"
#             )
   

            
            
        
    
    
    
#     Template.transfers.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'transfer', 20, ->
#         @autorun => Meteor.subscribe 'all_users', ->
            
            
#     Template.transfers.events
#         'click .add_transfer': ->
#             new_id = 
#                 Docs.insert 
#                     model:'transfer'
            
#             Router.go "/transfer/#{new_id}"
#             Meteor.users.update Meteor.userId(),
#                 editing:true
            
        
# # if Meteor.isServer
# #     Meteor.publish 'transfer_products', (transfer_id)->
# #         Docs.find   
# #             model:'product'
# #             transfer_id:transfer_id
            
            
# # if Meteor.isClient
# #     Template.transfer_view.onCreated ->
# #         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
# #         # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
# #         @autorun => Meteor.subscribe 'username_search', Session.get('username_query'), ->


# #     Template.user_picker.helpers
# #         unpicked_users: ->
# #             current_transfer = Docs.findOne Router.current().params.doc_id
# #             Meteor.users.find 
# #                 _id:$ne:current_transfer.recipient
# #         picked_user: ->
# #             current_transfer = Docs.findOne Router.current().params.doc_id
# #             Meteor.users.findOne 
# #                 _id:current_transfer.recipient
                
# #     Template.user_picker.events
# #         'click .pick_user': ->
# #             Docs.update Router.current().params.doc_id,
# #                 $set:recipient:@_id
# #         'keyup .search_user': ->
# #             val = $('.search_user').val()
# #             Session.set('username_query',val)
        
# #     Template.transfer_view.events
# #         'click .delete_transfer':->
# #             if confirm 'delete?'
# #                 Docs.remove @_id
# #                 Router.go "/transfers"

            
# #     Template.transfer_view.helpers
# #         all_shop: ->
# #             Docs.find
# #                 model:'transfer'
                
# # if Meteor.isServer
# #     Meteor.publish 'username_search', (query)->
# #         console.log 'search', query
# #         Meteor.users.find 
# #             username:{$regex:query,$options:'i'}


# if Meteor.isClient
#     Template.transfer_view.onCreated ->
#         # @autorun => Meteor.su    Template.user_credit.onCreated ->
#         @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username, ->
#         # @autorun => Meteor.subscribe 'model_docs', 'deposit'
#         # @autorun => Meteor.subscribe 'model_docs', 'reservation'
#         # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
#         # @autorun => Meteor.subscribe 'my_topups'
#         if Meteor.isDevelopment
#             pub_key = Meteor.settings.public.stripe_test_publishable
#         else if Meteor.isProduction
#             pub_key = Meteor.settings.public.stripe_live_publishable
#         Template.instance().checkout = StripeCheckout.configure(
#             key: pub_key
#             image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
#             locale: 'auto'
#             # zipCode: true
#             token: (token) ->
#                 # product = Docs.findOne Router.current().params.doc_id
#                 user = Meteor.users.findOne username:Router.current().params.username
#                 deposit_amount = parseInt $('.deposit_amount').val()*100
#                 stripe_charge = deposit_amount*100*1.02+20
#                 # calculated_amount = deposit_amount*100
#                 # console.log calculated_amount
#                 charge =
#                     amount: deposit_amount*1.02+20
#                     currency: 'usd'
#                     source: token.id
#                     description: token.description
#                     # receipt_email: token.email
#                 Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
#                     if error then alert error.reason, 'danger'
#                     else
#                         alert 'payment received', 'success'
#                         Docs.insert
#                             model:'deposit'
#                             deposit_amount:deposit_amount/100
#                             stripe_charge:stripe_charge
#                             amount_with_bonus:deposit_amount*1.05/100
#                             bonus:deposit_amount*.05/100
#                         Meteor.users.update user._id,
#                             $inc: credit: deposit_amount*1.05/100
#     	)
#     Template.buy_coin.onCreated ->
#         # @autorun => Meteor.su    Template.user_credit.onCreated ->
#         # @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username, ->
#         # @autorun => Meteor.subscribe 'model_docs', 'deposit'
#         # @autorun => Meteor.subscribe 'model_docs', 'reservation'
#         # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
#         # @autorun => Meteor.subscribe 'my_topups'
#         pub_key = Meteor.settings.public.stripe_test_publishable
#         # if Meteor.isDevelopment
#         #     pub_key = Meteor.settings.public.stripe_test_publishable
#         # else if Meteor.isProduction
#         #     pub_key = Meteor.settings.public.stripe_live_publishable
#         Template.instance().checkout = StripeCheckout.configure(
#             key: pub_key
#             image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
#             locale: 'auto'
#             # zipCode: true
#             token: (token) ->
#                 console.log @
#                 console.log Template.currentData()
#                 console.log Template.instance()
                
#                 # product = Docs.findOne Router.current().params.doc_id
#                 user = Meteor.users.findOne username:Router.current().params.username
#                 deposit_amount = parseInt $('.deposit_amount').val()*100
#                 stripe_charge = deposit_amount*100*1.02+20
#                 # calculated_amount = deposit_amount*100
#                 # console.log calculated_amount
#                 charge =
#                     amount: deposit_amount*1.02+20
#                     currency: 'usd'
#                     source: token.id
#                     description: token.description
#                     # receipt_email: token.email
#                 Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
#                     if error then alert error.reason, 'danger'
#                     else
#                         alert 'payment received', 'success'
#                         Docs.insert
#                             model:'deposit'
#                             deposit_amount:deposit_amount/100
#                             stripe_charge:stripe_charge
#                             amount_with_bonus:deposit_amount*1.05/100
#                             bonus:deposit_amount*.05/100
#                         Meteor.users.update user._id,
#                             $inc: credit: deposit_amount*1.05/100
#     	)


#     Template.user_credit.events
#         'click .add_credits': ->
#             amount = parseInt $('.deposit_amount').val()
#             amount_times_100 = parseInt amount*100
#             calculated_amount = amount_times_100*1.02+20
#             Template.instance().checkout.open
#                 name: 'credit deposit'
#                 # email:Meteor.user().emails[0].address
#                 description: 'gold run'
#                 amount: calculated_amount
#             Docs.insert
#                 model:'deposit'
#                 amount: amount
#             Meteor.users.update Meteor.userId(),
#                 $inc: credit: amount_times_100


#         'click .initial_withdrawal': ->
#             withdrawal_amount = parseInt $('.withdrawal_amount').val()
#             if confirm "initiate withdrawal for #{withdrawal_amount}?"
#                 Docs.insert
#                     model:'withdrawal'
#                     amount: withdrawal_amount
#                     status: 'started'
#                     complete: false
#                 Meteor.users.update Meteor.userId(),
#                     $inc: credit: -withdrawal_amount

#         'click .cancel_withdrawal': ->
#             if confirm "cancel withdrawal for #{@amount}?"
#                 Docs.remove @_id
#                 Meteor.users.update Meteor.userId(),
#                     $inc: credit: @amount

#         'click .send_points': ->
#             new_id = 
#                 Docs.insert 
#                     model:'transfer'
#                     amount:10
#             Router.go "/transfer/#{new_id}/edit"


#     Template.user_credit.helpers
#         payments: ->
#             Docs.find {
#                 model:'payment'
#                 _author_username: Router.current().params.username
#             }, sort:_timestamp:-1
#         deposits: ->
#             Docs.find {
#                 model:'deposit'
#                 _author_username: Router.current().params.username
#             }, sort:_timestamp:-1
#         topups: ->
#             Docs.find {
#                 model:'topup'
#                 _author_username: Router.current().params.username
#             }, sort:_timestamp:-1



#     Template.user_credit.events
#         'click .add_credit': ->
#             user = Meteor.users.findOne(username:Router.current().params.username)
#             Meteor.users.update Meteor.userId(),
#                 $inc:points:10
#                 # $set:points:1
#         'click .remove_points': ->
#             user = Meteor.users.findOne(username:Router.current().params.username)
#             Meteor.users.update Meteor.userId(),
#                 $inc:points:-1
#         # 'click .add_credits': ->
#         #     deposit_amount = parseInt $('.deposit_amount').val()*100
#         #     calculated_amount = deposit_amount*1.02+20
            
#         #     Template.instance().checkout.open
#         #         name: 'credit deposit'
#         #         # email:Meteor.user().emails[0].address
#         #         description: 'gold run'
#         #         amount: calculated_amount


#     Template.transfer_view.onRendered ->
#         @autorun => Meteor.subscribe 'recipient_from_transfer_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
#         @autorun => @subscribe 'tag_results',
#             # Router.current().params.doc_id
#             picked_tags.array()
#             Session.get('searching')
#             Session.get('current_query')
#             Session.get('dummy')

#     Template.transfer_view.helpers
#         terms: ->
#             Terms.find()
#         suggestions: ->
#             Tags.find()
#         recipient: ->
#             transfer = Docs.findOne Router.current().params.doc_id
#             if transfer.recipient_id
#                 Meteor.users.findOne
#                     _id: transfer.recipient_id
#         members: ->
#             transfer = Docs.findOne Router.current().params.doc_id
#             Meteor.users.find({
#                 # levels: $in: ['member','domain']
#                 _id: $ne: Meteor.userId()
#             }, {
#                 sort:points:1
#                 limit:10
#                 })
#         # subtotal: ->
#         #     transfer = Docs.findOne Router.current().params.doc_id
#         #     transfer.amount*transfer.recipient_ids.length
        
#         point_max: ->
#             if Meteor.user().username is 'one'
#                 1000
#             else 
#                 Meteor.user().points
        
#         can_submit: ->
#             transfer = Docs.findOne Router.current().params.doc_id
#             transfer.amount and transfer.recipient_id
#     Template.transfer_view.events
#         'click .add_recipient': ->
#             Docs.update Router.current().params.doc_id,
#                 $set:
#                     recipient_id:@_id
#         'click .remove_recipient': ->
#             Docs.update Router.current().params.doc_id,
#                 $unset:
#                     recipient_id:1
#         'keyup .new_tag': _.throttle((e,t)->
#             query = $('.new_tag').val()
#             if query.length > 0
#                 Session.set('searching', true)
#             else
#                 Session.set('searching', false)
#             Session.set('current_query', query)
            
#             if e.which is 13
#                 element_val = t.$('.new_tag').val().toLowerCase().trim()
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:tags:element_val
#                 picked_tags.push element_val
#                 Meteor.call 'log_term', element_val, ->
#                 Session.set('searching', false)
#                 Session.set('current_query', '')
#                 Session.set('dummy', !Session.get('dummy'))
#                 t.$('.new_tag').val('')
#         , 1000)

#         'click .remove_element': (e,t)->
#             element = @valueOf()
#             field = Template.currentData()
#             picked_tags.remove element
#             Docs.update Router.current().params.doc_id,
#                 $pull:tags:element
#             t.$('.new_tag').focus()
#             t.$('.new_tag').val(element)
#             Session.set('dummy', !Session.get('dummy'))
    
    
#         'click .select_term': (e,t)->
#             # picked_tags.push @title
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:tags:@title
#             picked_tags.push @title
#             $('.new_tag').val('')
#             Session.set('current_query', '')
#             Session.set('searching', false)
#             Session.set('dummy', !Session.get('dummy'))


#         'click .cancel_transfer': ->
#             Swal.fire({
#                 title: "confirm cancel?"
#                 text: ""
#                 icon: 'question'
#                 showCancelButton: true,
#                 confirmButtonColor: 'red'
#                 confirmButtonText: 'confirm'
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Docs.remove @_id
#                     Router.go '/'
#             )
            
#         'click .submit': ->
#             Swal.fire({
#                 title: "confirm send #{@amount}pts?"
#                 text: ""
#                 icon: 'question'
#                 showCancelButton: true,
#                 confirmButtonColor: 'green'
#                 confirmButtonText: 'confirm'
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Meteor.call 'send_transfer', @_id, =>
#                         Swal.fire(
#                             title:"#{@amount} sent"
#                             icon:'success'
#                             showConfirmButton: false
#                             position: 'top-end',
#                             timer: 1000
#                         )
#                         Router.go "/transfer/#{@_id}"
#             )



# if Meteor.isServer
#     Meteor.publish 'deposits', ->
#         Docs.find 
#             model:'deposit'
#     Meteor.methods
#         send_transfer: (transfer_id)->
#             transfer = Docs.findOne transfer_id
#             recipient = Meteor.users.findOne transfer.recipient_id
#             transferer = Meteor.users.findOne transfer._author_id

#             console.log 'sending transfer', transfer
#             Meteor.call 'recalc_one_stats', recipient._id, ->
#             Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
#             Docs.update transfer_id,
#                 $set:
#                     submitted:true
#                     submitted_timestamp:Date.now()
#             return
            
            
            
# if Meteor.isClient
#     Template.transfer_view.onCreated ->
#         @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->



# if Meteor.isServer
#     Meteor.publish 'product_from_transfer_id', (transfer_id)->
#         transfer = Docs.findOne transfer_id
#         Docs.find 
#             _id:transfer.product_id            