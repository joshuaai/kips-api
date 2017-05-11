require 'test_helper'

class LinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lin = lins(:one)
  end

  test "should get index" do
    get lins_url, as: :json
    assert_response :success
  end

  test "should create lin" do
    assert_difference('Lin.count') do
      post lins_url, params: { lin: { categ_id: @lin.categ_id, link_url: @lin.link_url, title: @lin.title } }, as: :json
    end

    assert_response 201
  end

  test "should show lin" do
    get lin_url(@lin), as: :json
    assert_response :success
  end

  test "should update lin" do
    patch lin_url(@lin), params: { lin: { categ_id: @lin.categ_id, link_url: @lin.link_url, title: @lin.title } }, as: :json
    assert_response 200
  end

  test "should destroy lin" do
    assert_difference('Lin.count', -1) do
      delete lin_url(@lin), as: :json
    end

    assert_response 204
  end
end
