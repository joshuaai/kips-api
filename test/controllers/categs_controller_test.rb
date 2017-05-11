require 'test_helper'

class CategsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @categ = categs(:one)
  end

  test "should get index" do
    get categs_url, as: :json
    assert_response :success
  end

  test "should create categ" do
    assert_difference('Categ.count') do
      post categs_url, params: { categ: { email: @categ.email, name: @categ.name } }, as: :json
    end

    assert_response 201
  end

  test "should show categ" do
    get categ_url(@categ), as: :json
    assert_response :success
  end

  test "should update categ" do
    patch categ_url(@categ), params: { categ: { email: @categ.email, name: @categ.name } }, as: :json
    assert_response 200
  end

  test "should destroy categ" do
    assert_difference('Categ.count', -1) do
      delete categ_url(@categ), as: :json
    end

    assert_response 204
  end
end
