require 'test_helper'

class AssignmentLinesControllerTest < ActionController::TestCase
  setup do
    @assignment_line = assignment_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assignment_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assignment_line" do
    assert_difference('AssignmentLine.count') do
      post :create, assignment_line: { line: @assignment_line.line, numbers: @assignment_line.numbers, assignment_id: @assignment_line.assignment_id, street_id: @assignment_line.street_id }
    end

    assert_redirected_to assignment_line_path(assigns(:assignment_line))
  end

  test "should show assignment_line" do
    get :show, id: @assignment_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @assignment_line
    assert_response :success
  end

  test "should update assignment_line" do
    patch :update, id: @assignment_line, assignment_line: { line: @assignment_line.line, numbers: @assignment_line.numbers, assignment_id: @assignment_line.assignment_id, street_id: @assignment_line.street_id }
    assert_redirected_to assignment_line_path(assigns(:assignment_line))
  end

  test "should destroy assignment_line" do
    assert_difference('AssignmentLine.count', -1) do
      delete :destroy, id: @assignment_line
    end

    assert_redirected_to assignment_lines_path
  end
end
