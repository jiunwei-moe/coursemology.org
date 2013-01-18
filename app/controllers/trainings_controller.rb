class TrainingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course, except: [:index]

  before_filter :load_general_course_data, only: [:show, :index, :edit, :new]

  def index
    @is_new = {}
    if curr_user_course.id
      @trainings = curr_user_course.get_trainings
      unseen = curr_user_course.get_unseen_trainings
      unseen.each do |tn|
        @is_new[tn.id] = true
        curr_user_course.mark_as_seen(tn)
      end
    else
      @trainings = @course.trainings.opened.order("open_at DESC")
    end
    @trainings_with_sbm = []
    @trainings.each do |training|
      if curr_user_course.id
        std_sbm = TrainingSubmission.find_by_std_course_id_and_training_id(
          curr_user_course.id,
          training.id
        )
      end
      @trainings_with_sbm << {
        training: training,
        submission: std_sbm
      }
    end
  end

  def show
    @mcqs = @training.mcqs
    if curr_user_course.is_student?
      @submission = @training.get_final_sbm_by_std(curr_user_course)
    end
  end

  def new
    @training.exp = 1000
    @training.open_at = DateTime.now
    @tags = @course.tags
  end

  def create
    @training.pos = @course.trainings.count - 1
    @training.creator = current_user
    @training.update_tags(params[:asm_tags], params[:tags])
    respond_to do |format|
      if @training.save
        format.html { redirect_to course_training_url(@course, @training),
                      notice: 'Training was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @tags = @course.tags
  end

  def update
    @training.update_tags(params[:asm_tags], params[:tags])
    respond_to do |format|
      if @training.update_attributes(params[:training])
        format.html { redirect_to course_training_url(@course, @training),
                      notice: 'Training was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @training.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @training.destroy

    respond_to do |format|
      format.html { redirect_to course_trainings_url }
    end
  end
end
