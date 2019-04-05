class Team < ApplicationRecord
    validates_presence_of :name
    validates_length_of :name, within: 4..30, too_long: 'Enter a shorter name', too_short: 'Enter a longer name', on: [:save, :update, :create]
    validates_uniqueness_of :name
end
