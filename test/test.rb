# frozen_string_literal: true
require "helper"
require "omniauth-weirdx"

class StrategyTest < StrategyTestCase
  include OAuth2StrategyTests
end

class ClientTest < StrategyTestCase
  test "has correct Weirdx site" do
    assert_equal "https://www.weirdx.io", strategy.client.site
  end

  test "has correct authorize url" do
    assert_equal "api/o/authorize/", strategy.client.options[:authorize_url]
  end

  test "has correct token url" do
    assert_equal "/api/o/token/", strategy.client.options[:token_url]
  end
end
class CallbackUrlTest < StrategyTestCase
  test "returns the default callback url" do
    url_base = "http://auth.request.com"
    @request.stubs(:url).returns("#{url_base}/some/page")
    strategy.stubs(:script_name).returns("") # as not to depend on Rack env
    assert_equal "#{url_base}/auth/weirdx/callback", strategy.callback_url
  end

  test "returns path from callback_path option" do
    @options = { callback_path: "/auth/weirdx/done" }
    url_base = "http://auth.request.com"
    @request.stubs(:url).returns("#{url_base}/page/path")
    strategy.stubs(:script_name).returns("") # as not to depend on Rack env
    assert_equal "#{url_base}/auth/weirdx/done", strategy.callback_url
  end
end

class UidTest < StrategyTestCase
  def setup
    super
    strategy.stubs(:raw_info).returns("id" => 10)
  end

  test "returns the user ID from raw_info" do
    assert_equal 10, strategy.uid
  end
end

class CredentialsTest < StrategyTestCase
  def setup
    super
    @access_token = stub("OAuth2::AccessToken")
    @access_token.stubs(:token)
    @access_token.stubs(:expires?)
    @access_token.stubs(:expires_at)
    @access_token.stubs(:refresh_token)
    strategy.stubs(:access_token).returns(@access_token)
  end

  test "returns a Hash" do
    assert_kind_of Hash, strategy.credentials
  end

  test "returns the token" do
    @access_token.stubs(:token).returns("tooooken")
    assert_equal "tooooken", strategy.credentials["token"]
  end

  test "returns the expiry status" do
    @access_token.stubs(:expires?).returns(true)
    assert strategy.credentials["expires"]

    @access_token.stubs(:expires?).returns(false)
    refute strategy.credentials["expires"]
  end

  test "returns the refresh token and expiry time when expiring" do
    ten_mins_from_now = (Time.now + 600).to_i
    @access_token.stubs(:expires?).returns(true)
    @access_token.stubs(:refresh_token).returns("re_toooooken")
    @access_token.stubs(:expires_at).returns(ten_mins_from_now)
    assert_equal "re_toooooken", strategy.credentials["refresh_token"]
    assert_equal ten_mins_from_now, strategy.credentials["expires_at"]
  end

  test "does not return the refresh token when test is nil and expiring" do
    @access_token.stubs(:expires?).returns(true)
    @access_token.stubs(:refresh_token).returns(nil)
    assert_nil strategy.credentials["refresh_token"]
    refute_has_key "refresh_token", strategy.credentials
  end

  test "does not return the refresh token when not expiring" do
    @access_token.stubs(:expires?).returns(false)
    @access_token.stubs(:refresh_token).returns("XXX")
    assert_nil strategy.credentials["refresh_token"]
    refute_has_key "refresh_token", strategy.credentials
  end
end

class PointTypeTest < StrategyTestCase
  def setup
    super
    @access_token = stub("OAuth2::AccessToken")
    strategy.stubs(:access_token).returns(@access_token)
  end

  test "performs a GET to https://weirdx.com/api/point_type" do
    strategy.stubs(:raw_info).returns("id" => "U10")
    @access_token.expects(:get)
                 .with("/api/point_type?user=U10")
                 .returns(stub_everything("OAuth2::Response"))
    strategy.point_type
  end

  test "URI escapes user ID" do
    strategy.stubs(:raw_info).returns("id" => "../haxx?U123#abc")
    @access_token.expects(:get)
                 .with("/api/point_type?user=..%2Fhaxx%3FU123%23abc")
                 .returns(stub_everything("OAuth2::Response"))
    strategy.point_type
  end
end

class PointListTest < StrategyTestCase
  def setup
    super
    @access_token = stub("OAuth2::AccessToken")
    strategy.stubs(:access_token).returns(@access_token)
  end

  test "performs a GET to https://weirdx.com/api/point" do
    strategy.stubs(:raw_info).returns("id" => "U10")
    @access_token.expects(:get)
                 .with("/api/point?user=U10")
                 .returns(stub_everything("OAuth2::Response"))
    strategy.point_list
  end

  test "URI escapes user ID" do
    strategy.stubs(:raw_info).returns("id" => "../haxx?U123#abc")
    @access_token.expects(:get)
                 .with("/api/point?user=..%2Fhaxx%3FU123%23abc")
                 .returns(stub_everything("OAuth2::Response"))
    strategy.point_list
  end
end
