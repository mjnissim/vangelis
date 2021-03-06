class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :complete]
  load_and_authorize_resource

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = current_campaign.all_assignments.order(id: :desc)
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
        format.html { redirect_to assignments_path, notice: 'Assignment was successfully created.' }
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
        format.html { redirect_to assignments_path, notice: 'Assignment was successfully updated.' }
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
    @assignment = Assignment.new( status: Assignment::COMPLETED )
    render :new
  end
  
  def generate
    if request.method == 'POST'
      notice = 'Assignments successfully generated.'
      if auto_generate
        redirect_to( assignments_path, notice: notice )
      else
        flash.now[:error] = "Couldn't create assignments. Maybe out of residences?"
        render :generate
      end
    end
  end

  def mapping
    @assignment = Assignment.new status: Assignment::MAPPING
    render :new
  end
  
  def send_link
    UserMailer.assignment( @assignment ).deliver
    notice = "Successfully sent link to #{ @assignment.assignee.nickname }"
    redirect_to assignments_path, notice: notice
    
    rescue
      flash[:error] = "Error when trying to send links."
      redirect_to assignments_path
  end
  
  def print
    url = params[:url].split( '-', 2 ).last
    @assignment = Assignment.find_by url: url
    render :printable, layout: false
  end
  
  def complete
    @assignment.update_attributes status: Assignment::COMPLETED
    redirect_to printable_assignment_path( @assignment )
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
      
      @assignments = assignments_from_lines( ag.assignment_lines, street ) 
      @assignments.any? and @assignments.all?(&:save)
    end
    
    def assignments_from_lines lines, street
      lines.map do |name, line|
        current_campaign.assignments.build( user: current_user, report: line,
          status: Assignment::ASSIGNED, city: street.city, name: name,
          assignee_id: params[:assignee_id])
      end
    end
end
