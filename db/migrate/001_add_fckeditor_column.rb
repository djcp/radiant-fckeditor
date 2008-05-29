class AddFckeditorColumn < ActiveRecord::Migration
  def self.up
    add_column :page_parts, :fckeditor, :boolean, :default => false
  end

  def self.down
    remove_column :page_parts, :fckeditor, :boolean
  end
end
