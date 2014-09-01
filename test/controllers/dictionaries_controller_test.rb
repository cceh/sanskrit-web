require 'test_helper'

class DictionariesControllerTest < ActionController::TestCase
	setup do
		@dictionary = dictionaries(:monier)
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:dictionaries)
	end

	test "should show dictionary" do
		get :show, id: @dictionary
		assert_response :success
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
