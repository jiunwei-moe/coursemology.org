class TagsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :tag, through: :course

  before_filter :load_general_course_data, only: [:new, :edit, :show, :index]

  def new
    @tag_groups = @course.tag_groups
  end

  def create
    respond_to do |format|
      if @tag.save
        format.html { redirect_to course_tags_path(@course),
                      notice: "The tag '#{@tag.name}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @tag_groups = @course.tag_groups
  end

  def update
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to course_tags_path(@course),
                      notice: "The tag '#{@tag.name}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def show
    if curr_user_course.is_lecturer?
      @trainings = @tag.trainings
    else
      @trainings = @tag.trainings.opened
    end
  end

  def index
    @tag_groups = @course.tag_groups
  end
end