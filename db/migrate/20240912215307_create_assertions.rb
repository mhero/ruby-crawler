class CreateAssertions < ActiveRecord::Migration[7.2]
  def change
    create_table :assertions do |t|
      t.string :url
      t.string :text
      t.string :status
      t.integer :links_number
      t.integer :images_number

      t.timestamps
    end
  end
end
