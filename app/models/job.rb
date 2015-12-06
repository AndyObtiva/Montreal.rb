class Job < ActiveRecord::Base
  STATES = [:draft, :published, :archived]
  enum state: STATES
  belongs_to :organization
end
