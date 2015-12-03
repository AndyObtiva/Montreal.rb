class AddLegacySlugToNewsItem < ActiveRecord::Migration
  def change
    add_column :news_items, :legacy_slug, :string
  end
end
