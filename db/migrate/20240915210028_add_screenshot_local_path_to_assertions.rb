class AddScreenshotLocalPathToAssertions < ActiveRecord::Migration[7.2]
  def change
    add_column :assertions, :local_path, :string
  end
end
