class AssignmentLinesController < ApplicationController
  before_action :set_assignment_line, only: [:show, :edit, :update, :destroy]

  # GET /assignment_lines
  # GET /assignment_lines.json
  def index
    @assignment_lines = AssignmentLine.all
  end

  # GET /assignment_lines/1
  # GET /assignment_lines/1.json
  def show
  end

  # GET /assignment_lines/new
  def new
    @assignment_line = AssignmentLine.new
  end

  # GET /assignment_lines/1/edit
  def edit
  end

  # POST /assignment_lines
  # POST /assignment_lines.json
  def create
    @assignment_line = AssignmentLine.new(assignment_line_params)

    respond_to do |format|
      if @assignment_line.save
        format.html { redirect_to @assignment_line, notice: 'Assignment line was successfully created.' }
        format.json { render action: 'show', status: :created, location: @assignment_line }
      else
        format.html { render action: 'new' }
        format.json { render json: @assignment_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignment_lines/1
  # PATCH/PUT /assignment_lines/1.json
  def update
    respond_to do |format|
      if @assignment_line.update(assignment_line_params)
        format.html { redirect_to @assignment_line, notice: 'Assignment line was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @assignment_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignment_lines/1
  # DELETE /assignment_lines/1.json
  def destroy
    @assignment_line.destroy
    respond_to do |format|
      format.html { redirect_to assignment_lines_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment_line
      @assignment_line = AssignmentLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_line_params
      params.require(:assignment_line).permit(:assignment_id, :line, :street_id, :numbers)
    end
end
