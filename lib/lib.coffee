Meteor.methods
    upvote: (doc_id)->
        doc = Docs.findOne doc_id
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc_id)->
        doc = Docs.findOne doc_id
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:-1
