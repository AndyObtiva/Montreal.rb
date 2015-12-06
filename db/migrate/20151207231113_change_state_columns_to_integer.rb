class ChangeStateColumnsToInteger < ActiveRecord::Migration
  def up
    # Resetting string enum values to ensure they get stored as integers using
    # ActiveRecord::Enum instead of enumerize
    [Job, NewsItem, Page].each do |model_class|
      puts "\nProcessing #{model_class} models..."
      model_class.find_each do |model|
        state = model.attributes['state']
        puts "Current state: #{state.inspect}"
        if !state.blank? && model_class.states.include?(state)
          new_state = model_class.states[state]
          puts "updating to #{new_state}\n"
          model.update_columns(state: new_state)
        end
      end
    end

    # Updating columns to integer to switch to ActiveRecord::Enum, and adding
    # default value via database (as per ActiveRecord::Enum specification)
    [:jobs, :news_items, :pages].each do |table|
      change_column table, :state, 'integer USING CAST(state AS integer)', null: false, default: 0
    end
  end

  def down
    change_column :jobs, :state, :string, null: true, default: nil
    change_column :news_items, :state, :string, null: true, default: nil
    change_column :pages, :state, :string, null: true, default: nil

    [Job, NewsItem, Page].each do |model_class|
      puts "\nProcessing #{model_class} models..."
      model_class.find_each do |model|
        state = model.attributes['state']
        puts "Current state: #{state.inspect}"
        if !state.blank? && model_class.states.values.map(&:to_s).include?(state)
          new_state = model_class.states.invert[state.to_i]
          puts "updating to #{new_state}\n"
          model.update_columns(state: new_state)
        end
      end
    end
  end
end
