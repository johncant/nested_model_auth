# NestedModelAuth

nested\_model\_auth is a simple model based authentication nanoframework for use with ActiveRecord. All it does is provide convenient methods of determining whether a new or changed record should be allowed to be saved by a user. The goal is to provide a method which can be hooked into by <a href=https://github.com/ryanb/cancan>CanCan</a> to authorize saving of new or changed records to protect against mass assignment vulnerabilities. Please note that this gem does not depend on CanCan, and I don't presume to tell you how you _should_ use this gem, but only how to use it and how I intend to use it.

# Mass assignment vulnerbilities? Why not just use attr\_protected or attr\_accessible?

Imagine you have a collection of associated models which you want to mass assign. If you lock down some of the attributes using attr\_protected/attr\_accessible, then (1) You can't mass assign from the console and (2) The attributes are locked down for every user. It also seems weird to break such a powerful feature as mass assignment by having security built into it rather than called from the controller.

If, instead, you use CanCan or something, you can use this gem to determine which users should be allowed to create or save which records. Think of it like a type of validation except that it depends on who tries to save the model, and that it prevents hacking and doesn't need to report back the errors.

Called nested\_model\_auth because I plan on making it recursive amongst new records for nested mass assignment. The result of allow\_save\_by? is cached to prevent an infinite loop

All feedback welcome!

<pre>
# Bad example here, but I hope it gets the point across

class GroupMembership < ActiveRecord::Base

  belongs\_to :group
  belongs\_to :account

  # Attributes are :group\_id, :account\_id, :role\_within\_group

  allow\_save\_by do |account|
    account_id == account.id
  end

  deny\_save\_by do |account|
    unless account.site_admin?
      group_id\_changed? if new_record? # This would prevent a hacker reassigning himself to a different group
    end
  end
    
end

# Elsewhere in your code

legit = Account.first.memberships.build(:role\_within\_group => "minion", :group\_id => @group.id)
legit.allow\_save\_by(Account.first) # true
legit.allow\_save\_by(Account.all[1]) # false

# User adds himself to a group and becomes admin
hack = @hacker.memberships.build(:role\_within\_group => "admin", :group\_id => Group.find\_by\_name("Nobody has heard of this one, and the hacker is the admin").id)
hack.allow_save_by(@hacker)
hack.save! # Worked. Legit so far...

# Hacker PUTs to the update controller method but with different data
hack.attributes={:role\_within\_group => "admin", :group\_id => Group.find\_by\_name("CIA - TOP SECRET! UNDER NO CIRCUMSTANCES SHOULD ANYONE BE ALLOWED ACCESS TO THIS GROUP")}

hack.allow\_save\_by(@hacker) # false - If we'd called this method from a CanCan rule, we would prevent the hack
hack.allow\_save\_by(Account.where(:is\_site\_admin => true).first) # true - If we were a site admin, we would be permitted to use mass assignment to change this record.

</pre>

## Installation

Add this line to your application's Gemfile:

    gem 'nested_model_auth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nested_model_auth

## Usage

Please see above!

## Testing

Unfortunately there are no specs beyond those which I wrote in my proprietary web app. Because this gem is so simple, I didn't feel the need to write any specs. Feel free to contribute!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
