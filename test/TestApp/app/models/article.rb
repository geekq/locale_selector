class Article < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_length_of :description, :minimum => 3
end

class ArticleProperty < ActiveRecord::Base
#  belongs_to Article
end