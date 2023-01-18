# Approaches to Confirming User Emails in Rails

## Approach 1

Use [signed_id][] without an expiration and purpose.

**Advantages**

- Links cannot be tampered with.
- Links are obfuscated.

**Disadvantages**

- Links can be used multiple times.
- Links do not expire.
- Links are not restricted.

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      # Generate Signed ID.
      signed_id = @user.signed_id

      # Share this URL in a Mailer.
      # edit_confirmation_url(signed_id)
      # https://www.example.com/confirmations/{signed_id}/edit
    end
  end
end
```

```ruby
Rails.application.routes.draw do
  # Add a route for processing confirmations. Use the `signed_id` as the identifier.
  resources :confirmations, only: :edit, param: :signed_id
end
```

```ruby
class ConfirmationsController < ApplicationController
  def edit
    # Find the unconfirmed user by their Signed ID so that they can be confirmed.
    @user = User.unconfirmed.find_signed!(params[:signed_id])
    @user.update!(confirmed_at: Time.current)
  end
end
```

## Approach 2

Use [signed_id][] with an expiration and purpose.

**Advantages**

- Links cannot be tampered with.
- Links are obfuscated.
- Links expire.
- Links are restricted.

**Disadvantages**

- Links can be used multiple times before expiring.

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      # Generate Signed ID with an expiration and purpose.
      signed_id = @user.signed_id expires_in: 15.minutes, purpose: :confirmation

      # Share this URL in a Mailer.
      # edit_confirmation_url(signed_id)
      # https://www.example.com/confirmations/{signed_id}/edit
    end
  end
end
```

```ruby
Rails.application.routes.draw do
  # Add a route for processing confirmations. Use the `signed_id` as the identifier.
  resources :confirmations, only: :edit, param: :signed_id
end
```

```ruby
class ConfirmationsController < ApplicationController
  def edit
    # Find the unconfirmed user by their Signed ID with a purpose so that they can be confirmed.
    @user = User.unconfirmed.find_signed!(params[:signed_id], purpose: :confirmation)
    @user.update!(confirmed_at: Time.current)
  end
end
```

## Approach 3

Use [signed_id][] with an expiration and purpose on a proxy record.

**Advantages**

- Links cannot be tampered with.
- Links are obfuscated.
- Links expire.
- Links are restricted.
- Links cannot be used multiple times.
- Links can be revoked.
- Can be applied to multiple records.

**Disadvantages**

- Adds an additional database table.
- Can no longer scope query to unconfirmed accounts.

```ruby
class CreateConfirmations < ActiveRecord::Migration[7.0]
  def change
    create_table :confirmations do |t|
      t.references :confirmable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
```

```ruby
class Confirmation < ApplicationRecord
  belongs_to :confirmable, polymorphic: true
end
```

```ruby
class User < ApplicationRecord
  has_many :confirmations, as: :confirmable
end
```

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      # Create a new confirmation record associated with the user.
      confirmation = @user.confirmations.create!
      # Generate Signed ID with an expiration and purpose.
      signed_id = confirmation.signed_id expires_in: 15.minutes, purpose: :confirmation

      # Share this URL in a Mailer.
      # edit_confirmation_url(signed_id)
      # https://www.example.com/confirmations/{signed_id}/edit
    end
  end
end
```

```ruby
Rails.application.routes.draw do
  # Add a route for processing confirmations. Use the `signed_id` as the identifier.
  resources :confirmations, only: :edit, param: :signed_id
end
```

```ruby
class ConfirmationsController < ApplicationController
  def edit
    # Find the unconfirmed user via a proxy so that they can be confirmed.
    @confirmation = Confirmation.find_signed!(params[:signed_id], purpose: :confirmation)
    @confirmation.confirmable.update!(confirmed_at: Time.current)

    # Destroy any existing confirmations for that record so they cannot be used.
    @confirmation.confirmable.confirmations.destroy_all!
  end
end
```

### Modifications

Limit the number of confirmations a record can be associated with to one.

```ruby
class AddUniqueConstraintToConfirmations < ActiveRecord::Migration[7.0]
  def change
    add_index :confirmations, [:confirmable_id, :confirmable_type], unique: true
  end
end
```

```ruby
class Confirmation < ApplicationRecord
  belongs_to :confirmable, polymorphic: true

  validates :confirmable_type, uniqueness: { scope: :confirmable_id }
end
```

```ruby
class User < ApplicationRecord
  has_one :confirmation, as: :confirmable
end
```

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      # Create a new confirmation record associated with the user.
      confirmation = @user.create_confirmation!
      # Generate Signed ID with an expiration and purpose.
      signed_id = confirmation.signed_id expires_in: 15.minutes, purpose: :confirmation

      # Share this URL in a Mailer.
      # edit_confirmation_url(signed_id)
      # https://www.example.com/confirmations/{signed_id}/edit
    end
  end
end
```

```ruby
class ConfirmationsController < ApplicationController
  def edit
    # Find the unconfirmed user via a proxy so that they can be confirmed.
    @confirmation = Confirmation.find_signed!(params[:signed_id], purpose: :confirmation)
    @confirmation.confirmable.update!(confirmed_at: Time.current)

    # Destroy the confirmation.
    @confirmation.destroy!
  end
end
```

[signed_id]: https://api.rubyonrails.org/classes/ActiveRecord/SignedId.html#method-i-signed_id
