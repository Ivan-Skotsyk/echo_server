class CreateEndpoints < ActiveRecord::Migration[7.1]
  def change
    create_table :endpoints do |t|
      t.string :verb
      t.string :path
      t.integer :code
      t.string :headers
      t.text :body
      t.timestamps

      t.index [:verb, :path], unique: true
    end
  end
end
