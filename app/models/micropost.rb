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
  before_save :set_in_reply_to

  def Micropost.including_replies(id)
    where(in_reply_to: [id, 0]).or(Micropost.where(user_id: id)).distinct
  end
  

  def set_in_reply_to
    if match = content.match(/@([a-zA-Z0-9_\-]+)/)
      user_name = match[1]
      user = User.find_by(user_name: user_name)
      self.in_reply_to = user ? user.id : 0
    else
      self.in_reply_to = 0
    end
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
    unless reply_to_user_name_correct?
      errors.add(:base, "User ID doesn't match its name.")
    end
  end
  
  def reply_to_user_name_correct?
    if match = content.match(/@([a-zA-Z0-9_\-]+)/)
      user_name = match[1]
      User.exists?(user_name: user_name)
    else
      false
    end
  end

end

