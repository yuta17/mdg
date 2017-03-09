require 'active_record'

module Mdg
  class Timestamp < ActiveRecord::Base
    belongs_to :deed
  end
end
