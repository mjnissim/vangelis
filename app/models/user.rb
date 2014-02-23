class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :current_campaign, foreign_key: :current_campaign_id,
          class_name: 'Campaign'
  validates :nickname, presence: true
  
  def assignments
    Assignment.where('user_id = :user OR assignee_id = :user', user: self)
  end
  
  def self.admin
    where( admin: true ).first
  end
end
