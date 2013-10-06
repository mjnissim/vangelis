require 'test_helper'

class OutingLinesControllerTest < ActionController::TestCase
  setup do
    @outing_line = outing_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:outing_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create outing_line" do
    assert_difference('OutingLine.count') do
      post :create, outing_line: { line: @outing_line.line, numbers: @outing_line.numbers, outing_id: @outing_line.outing_id, street_id: @outing_line.street_id }
    end

    assert_redirected_to outing_line_path(assigns(:outing_line))
  end

  test "should show outing_line" do
    get :show, id: @outing_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @outing_line
    assert_response :success
  end

  test "should update outing_line" do
    patch :update, id: @outing_line, outing_line: { line: @outing_line.line, numbers: @outing_line.numbers, outing_id: @outing_line.outing_id, street_id: @outing_line.street_id }
    assert_redirected_to outing_line_path(assigns(:outing_line))
  end

  test "should destroy outing_line" do
    assert_difference('OutingLine.count', -1) do
      delete :destroy, id: @outing_line
    end

    assert_redirected_to outing_lines_path
  end
end
