class NewsItem < ActiveRecord::Base
  STATES = [:draft, :published, :archived]
  enum state: STATES
  # declare this scope to set order, even if it comes with enum automatically.
  scope(:published, lambda do
    where(state: NewsItem.states(:published)).order(:published_at)
  end)
  validates :published_at, presence: true, if: -> { published? }
  validates_presence_of :title, :state
end
