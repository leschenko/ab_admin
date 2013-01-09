# -*- encoding : utf-8 -*-
class Header < ActiveRecord::Base

  attr_accessible :title, :keywords, :description

  translates :title, :keywords, :description

  include AbAdmin::Models::Header

end

# == Schema Information
#
# Table name: headers
#
#  id              :integer          not null, primary key
#  headerable_type :string(30)       not null
#  headerable_id   :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

