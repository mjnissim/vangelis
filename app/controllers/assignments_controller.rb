class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = Assignment.all.order(id: :desc)
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments
  # POST /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @assignment }
      else
        [:"lines.base", :lines].each{|key| @assignment.errors.delete(key) }
        flash.now[:error] = @assignment.errors.full_messages
        format.html { render action: 'new' }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to assignments_url }
      format.json { head :no_content }
    end
  end
  
  def report
    @assignment = Assignment.new( status: Assignment::STATUSES[:completed] )
    render :new
  end
  
  def generate
    if request.method == 'POST'
      notice = 'Assignments generated successfully.'
      redirect_to( assignments_url, notice: notice ) if auto_generate
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.includes(:lines).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.require(:assignment).permit(
        :user_id, :campaign_id, :date, :status, :city_id, :comments, :report,
        :lines_attributes => [
          :line, :confirmed_street_name
        ]
      )
    end
    
    def auto_generate
      street = Street.find( params[:street_id] )
      
      ag = AssignmentGenerator.new( current_campaign, street,
        params[:amount], params[:residences_each] )
      groups = ag.generate
      residences_to_assignments street, groups
    end
    
    def residences_to_assignments street, residence_groups
      @assignments = residence_groups.map do |grp|
        residence_to_assignment street, grp
      end
      @assignments.all?(&:save)
    end
    
    def residence_to_assignment street, grp
      report = "#{ street.name } #{grp.map{ |b| b.building + '/' +
        b.covered_flats.first.to_s }.join( ', ' ) }"
      puts report
      current_campaign.assignments.build( user: current_user, report: report,
        status: Assignment::STATUSES[:assigned], city: street.city)
    end
end
