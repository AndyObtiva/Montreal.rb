class Page < ActiveRecord::Base
  translates :title, :body

  validates :title, presence: true
  validates :state, presence: true

  enum state: [:draft, :published, :archived]
end
