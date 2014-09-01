require 'test_helper'

class LemmasControllerTest < ActionController::TestCase
	setup do
		@lemma = lemmas(:one)
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:lemmas)
	end

	test "should show lemma" do
		get :show, id: @lemma
		assert_response :success
	end
end

# Licensed under the ISC licence, see LICENCE.ISC for details
