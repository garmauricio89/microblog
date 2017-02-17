class CreatePostsTable < ActiveRecord::Migration
  def change
  	create_table :posts do |t|
  		t.string :line1
  		t.integer :user_id
  		t.integer :likes
  	end
  end
end
