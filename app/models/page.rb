class Page < ActiveRecord::Base
  translates :title, :body

  validates :title, presence: true

  enum state: [:draft, :published, :archived]
end
