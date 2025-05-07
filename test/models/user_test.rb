require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",user_name:"example",
                      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn ]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
    # ユーザーは自分自身をフォローできない
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test "ユーザー名：存在性に対するバリデーション" do
    @user.user_name = ""
    assert_not @user.valid?
  end
  
  test "ユーザー名：一意性に対するバリデーション" do
    duplicate_user = @user.dup
    duplicate_user.user_name = @user.user_name.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "ユーザー名：使用可能な文字列のバリデーション" do
    valid_user_names = %w[yutachan taro2 3Shiro Boys2Men]
    valid_user_names.each do |valid_user_name|
      @user.user_name = valid_user_name
      assert @user.valid?, "#{valid_user_name.inspect}は使用可能"
    end
  end
  
  test "ユーザー名：使用不可な文字列のバリデーション" do
    invalid_user_names = %w[yuta-chan Taro@San 3.sHiro boY.2/meN あいう]
    invalid_user_names.each do |invalid_user_name|
      @user.user_name = invalid_user_name
      assert_not @user.valid?, "#{invalid_user_name.inspect}は使用不可"
    end
  end

  test "should return the right feed" do
    michael = users(:michael)
    lana = users(:lana)
  
    # フォローしているユーザーの投稿を作成
    lana.microposts.create!(content: "Lana's post")
    feed = michael.feed
  
    # フィードにLanaの投稿が含まれているかを確認
    assert feed.include?(lana.microposts.first)
  end

  test "michael's posts should appear in his feed" do
    michael = users(:michael)
    micropost = michael.microposts.create!(content: "Michael's post")
  
    # 自分の投稿がフィードに含まれているか確認
    assert_includes michael.feed, micropost
  end
  
  test "should not include unfollowed users' posts in feed" do
    michael = users(:michael)
    archer = users(:archer)
    post_unfollowed = archer.microposts.create!(content: "Archer's post")
  
    # フォローしていないユーザーの投稿がフィードに含まれていないことを確認
    assert_not michael.feed.include?(post_unfollowed)
  end

  test "フォローしているユーザーの自分へのメンションが見える" do
    michael = users(:michael)
    lana = users(:lana)
    # フォローしているユーザーの投稿を作成
    micropost = lana.microposts.create!(content: "@Michael Lana's post")
    feed = michael.feed
    # フィードにLanaの投稿が含まれているかを確認
    assert feed.include?(micropost)
  end

  test "フォローしていないユーザーの自分へのメンションが見える" do
    michael = users(:michael)
    archer = users(:archer)
    # フォローしているユーザーの投稿を作成
    micropost = archer.microposts.create!(content: "@Michael archer's post")
    feed = michael.feed
    # フィードに投稿が含まれているかを確認
    assert feed.include?(micropost)
  end

  test "フォローしている他人へのメンションは見えない" do
    michael = users(:michael)
    lana = users(:lana)
    malory = users(:malory)
    # フォローしているユーザーの投稿を作成
    micropost = lana.microposts.create!(content: "@malory Lana's post")
    feed = michael.feed
    # フィードにLanaの投稿が含まれているかを確認
    assert_not feed.include?(micropost)
  end
end

