require 'test_helper'

class ScansControllerTest < ActionController::TestCase
  setup do
    @scan = scans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scans)
  end

  test "should show scan" do
    get :show, id: @scan
    assert_response :success
  end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
