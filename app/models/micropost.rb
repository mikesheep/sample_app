class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }  #降順(Udesc)に並べ替え
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message:   "should be less than 5MB" }

  before_validation :set_in_reply_to 
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validates :in_reply_to, presence: false
  validate :reply_to_user 

  def self.including_replies(user)
    following_ids = user.following_ids
    where(user_id: following_ids + [user.id])
      .or(where(in_reply_to: user.id))
  end  

  def set_in_reply_to
    ids = content.scan(/@(\d+)/).flatten.map(&:to_i)
    self.in_reply_to = ids.first || 0
  end

  def reply_to_user
    # メンションがない場合
    return if self.in_reply_to == 0
    # メンション先ユーザーが存在しない場合
    user = User.find_by(id: self.in_reply_to)
    if user.nil?
      errors.add(:base, "User ID you specified doesn't exist.")
      return
    end
    # メンション先が自分自身の場合
    if self.user_id == self.in_reply_to
      errors.add(:base, "You can't reply to yourself.")
      return
    end
    # 名前とIDが一致しない場合
    unless reply_to_user_name_correct?(user)
      errors.add(:base, "User ID doesn't match its name.")
    end
  end
  
  def reply_to_user_name_correct?(user)
    user_name = user.name.gsub(" ", "-")
    content[@index+2, user_name.length] == user_name
  end

  # def picture_size
  #   if picture.attached? && picture.byte_size > 5.megabytes
  #     errors.add(:picture, "is too big. Maximum allowed size is 5MB.")
  #   end
  # end
end

