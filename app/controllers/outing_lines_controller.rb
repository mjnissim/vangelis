class OutingLinesController < ApplicationController
  before_action :set_outing_line, only: [:show, :edit, :update, :destroy]

  # GET /outing_lines
  # GET /outing_lines.json
  def index
    @outing_lines = OutingLine.all
  end

  # GET /outing_lines/1
  # GET /outing_lines/1.json
  def show
  end

  # GET /outing_lines/new
  def new
    @outing_line = OutingLine.new
  end

  # GET /outing_lines/1/edit
  def edit
  end

  # POST /outing_lines
  # POST /outing_lines.json
  def create
    @outing_line = OutingLine.new(outing_line_params)

    respond_to do |format|
      if @outing_line.save
        format.html { redirect_to @outing_line, notice: 'Outing line was successfully created.' }
        format.json { render action: 'show', status: :created, location: @outing_line }
      else
        format.html { render action: 'new' }
        format.json { render json: @outing_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /outing_lines/1
  # PATCH/PUT /outing_lines/1.json
  def update
    respond_to do |format|
      if @outing_line.update(outing_line_params)
        format.html { redirect_to @outing_line, notice: 'Outing line was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @outing_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outing_lines/1
  # DELETE /outing_lines/1.json
  def destroy
    @outing_line.destroy
    respond_to do |format|
      format.html { redirect_to outing_lines_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outing_line
      @outing_line = OutingLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def outing_line_params
      params.require(:outing_line).permit(:outing_id, :line, :street_id, :numbers)
    end
end
